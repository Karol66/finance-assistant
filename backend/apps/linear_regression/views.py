from decimal import Decimal
import joblib
import numpy as np
import pandas as pd
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from datetime import timedelta

from apps.goals.models import Goal
from apps.transfers.models import Transfer

model = joblib.load('ai/model_regresji_liniowej.pkl')
scaler = joblib.load('ai/scaler.pkl')


def get_predicted_savings(user):
    transfers = Transfer.objects.filter(account__user=user, is_deleted=False).select_related('category')
    data = [
        {
            'amount': transfer.amount,
            'date': transfer.date,
            'category_type': transfer.category.category_type if transfer.category else None
        }
        for transfer in transfers
    ]
    df = pd.DataFrame(data)

    if df.empty:
        return None, {'error': 'No historical data found for predictions.'}

    df['amount'] = df['amount'].astype(float)
    df['date'] = pd.to_datetime(df['date']).dt.tz_localize(None)

    daily_data = df.groupby('date').agg({'amount': 'sum'}).reset_index()
    daily_data.columns = ['Date', 'Net Income']
    daily_data['Cumulative Savings'] = daily_data['Net Income'].cumsum()

    predicted_savings = []
    last_date = daily_data['Date'].iloc[-1]
    last_savings = daily_data['Cumulative Savings'].iloc[-1]

    future_dates = []
    for day in range(1, 366):
        next_date = last_date + timedelta(days=1)
        month = next_date.month
        day_of_year = next_date.dayofyear

        input_data = pd.DataFrame([[month, day_of_year, last_savings]],
                                  columns=['Month', 'DayOfYear', 'Cumulative Savings'])
        scaled_data = pd.DataFrame(scaler.transform(input_data),
                                   columns=input_data.columns)
        predicted_saving = model.predict(scaled_data)[0]

        predicted_savings.append(predicted_saving)
        last_savings = predicted_saving
        last_date = next_date
        future_dates.append(next_date)

    predicted_future_df = pd.DataFrame({'Date': future_dates, 'Predicted Daily Savings': predicted_savings})
    predicted_future_df['Month'] = predicted_future_df['Date'].dt.to_period('M')
    monthly_predicted_savings = predicted_future_df.groupby('Month')['Predicted Daily Savings'].sum().reset_index()

    return monthly_predicted_savings['Predicted Daily Savings'].tolist(), None


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def predict_savings_for_next_12_months(request):
    predicted_savings, error = get_predicted_savings(request.user)
    if error:
        return Response(error, status=status.HTTP_404_NOT_FOUND)

    return Response({'predicted_savings': predicted_savings}, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def propose_saving_strategy(request):
    goals = Goal.objects.filter(user=request.user, is_deleted=False)
    if not goals.exists():
        return Response({"error": "No goals found for the user."}, status=status.HTTP_404_NOT_FOUND)

    predicted_savings, error = get_predicted_savings(request.user)
    if error:
        return Response(error, status=status.HTTP_404_NOT_FOUND)

    total_goal_priority = sum(goal.priority for goal in goals)
    strategy = []

    for goal in goals:
        goal_target = Decimal(goal.target_amount)
        goal_priority = goal.priority
        cumulative_savings = Decimal(0)
        months_needed = 0
        monthly_allocation = []

        for saving in predicted_savings:
            if saving <= 0:
                continue

            if cumulative_savings >= goal_target:
                break

            allocated_saving = Decimal(saving) * (Decimal(goal_priority) / Decimal(total_goal_priority))
            allocated_saving = max(Decimal(0), min(allocated_saving, goal_target - cumulative_savings))
            cumulative_savings += allocated_saving
            monthly_allocation.append(round(float(allocated_saving), 2))

            months_needed += 1

        estimated_achievement_date = pd.Timestamp.today() + timedelta(days=30 * months_needed)
        strategy.append({
            'goal': goal.goal_name,
            'goal_icon': goal.goal_icon,
            'target_amount': float(goal_target),
            'estimated_achievement_date': estimated_achievement_date.date(),
            'monthly_allocation': monthly_allocation
        })

    return Response({
        'strategy': strategy,
        'message': 'Saving strategy calculated successfully'
    }, status=status.HTTP_200_OK)

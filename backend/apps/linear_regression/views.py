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

# Load model and scaler
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
    df['YearMonth'] = df['date'].dt.to_period('M')
    income_df = df[df['category_type'] == 'income'].groupby('YearMonth')['amount'].sum().reset_index()
    expenses_df = df[df['category_type'] == 'expense'].groupby('YearMonth')['amount'].sum().reset_index()
    monthly_data = pd.merge(income_df, expenses_df, on='YearMonth', how='outer', suffixes=('_income', '_expense')).fillna(0)
    monthly_data.rename(columns={'amount_income': 'income', 'amount_expense': 'expenses'}, inplace=True)
    monthly_data['savings'] = monthly_data['income'] - monthly_data['expenses']

    predicted_savings = []
    last_income = monthly_data.iloc[-1]['income'] if not monthly_data.empty else 0
    last_expenses = monthly_data.iloc[-1]['expenses'] if not monthly_data.empty else 0

    for _ in range(12):
        input_data = pd.DataFrame([[last_income, last_expenses]], columns=['income', 'expenses'])
        scaled_data = scaler.transform(input_data)
        predicted_saving = model.predict(scaled_data)[0]
        predicted_savings.append(predicted_saving)
        last_income += np.random.normal(0, 50)
        last_expenses += np.random.normal(0, 50)

    return predicted_savings, None

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

    # Use the priority field instead of weight
    total_goal_priority = sum(goal.priority for goal in goals)
    strategy = []

    for goal in goals:
        goal_target = goal.target_amount
        goal_priority = goal.priority
        allocated_savings = [saving * (goal_priority / total_goal_priority) for saving in predicted_savings]
        cumulative_savings = 0
        months_needed = 0
        for i, saving in enumerate(allocated_savings):
            cumulative_savings += saving
            if cumulative_savings >= goal_target:
                months_needed = i + 1
                break
        estimated_achievement_date = pd.Timestamp.today() + timedelta(days=30 * months_needed)
        strategy.append({
            'goal': goal.goal_name,
            'target_amount': goal_target,
            'estimated_achievement_date': estimated_achievement_date.date(),
            'monthly_allocation': allocated_savings[:months_needed]
        })

    return Response({
        'strategy': strategy,
        'message': 'Saving strategy calculated successfully'
    }, status=status.HTTP_200_OK)

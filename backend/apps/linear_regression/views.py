from decimal import Decimal
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
import joblib
import pandas as pd
from apps.goals.models import Goal
from apps.transfers.models import Transfer
from apps.accounts.models import Account
from apps.categories.models import Category

income_model = joblib.load('ai/model_regresji_liniowej_income.pkl')
income_scaler = joblib.load('ai/scaler_income.pkl')
expense_model = joblib.load('ai/model_regresji_liniowej_expense.pkl')
expense_scaler = joblib.load('ai/scaler_expense.pkl')


def forecast_next_6_months(model, scaler, start_date, min_date):
    future_dates = pd.date_range(start=start_date, periods=6, freq='ME')
    future_days = (future_dates - min_date).days.values.reshape(-1, 1)
    future_days_df = pd.DataFrame(future_days, columns=['Days'])

    future_days_scaled = scaler.transform(future_days_df)
    future_predictions = model.predict(future_days_scaled)

    print(f"Forecast for model {model}: {future_predictions}")

    forecast_df = pd.DataFrame({
        'Data operacji': future_dates,
        'Predicted Amount': future_predictions
    })
    return forecast_df


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def predict_expenses(request):
    user_accounts = Account.objects.filter(user=request.user)
    user_transfers = Transfer.objects.filter(account_id__in=user_accounts, is_deleted=False)

    expense_categories = Category.objects.filter(category_type='expense').values_list('id', flat=True)
    expense_transfers = user_transfers.filter(category_id__in=expense_categories)

    data = pd.DataFrame(list(expense_transfers.values('date', 'amount')))
    data['date'] = pd.to_datetime(data['date'])
    data['Days'] = (data['date'] - data['date'].min()).dt.days

    last_date = data['date'].max()
    expense_forecast = forecast_next_6_months(expense_model, expense_scaler, last_date, data['date'].min())

    print("Expense forecast data:")
    print(expense_forecast)

    response_data = expense_forecast.to_dict(orient='records')
    return Response(response_data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def predict_income(request):
    user_accounts = Account.objects.filter(user=request.user)
    user_transfers = Transfer.objects.filter(account_id__in=user_accounts, is_deleted=False)

    # Filter transfers by categories marked as income
    income_categories = Category.objects.filter(category_type='income').values_list('id', flat=True)
    income_transfers = user_transfers.filter(category_id__in=income_categories)

    data = pd.DataFrame(list(income_transfers.values('date', 'amount')))
    data['date'] = pd.to_datetime(data['date'])
    data['Days'] = (data['date'] - data['date'].min()).dt.days

    last_date = data['date'].max()
    income_forecast = forecast_next_6_months(income_model, income_scaler, last_date, data['date'].min())

    print("Income forecast data:")
    print(income_forecast)

    response_data = income_forecast.to_dict(orient='records')
    return Response(response_data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def predict_net_savings(request):
    user_accounts = Account.objects.filter(user=request.user)
    user_transfers = Transfer.objects.filter(account_id__in=user_accounts, is_deleted=False)

    expense_categories = Category.objects.filter(category_type='expense').values_list('id', flat=True)
    income_categories = Category.objects.filter(category_type='income').values_list('id', flat=True)

    expense_transfers = user_transfers.filter(category_id__in=expense_categories)
    income_transfers = user_transfers.filter(category_id__in=income_categories)

    expense_data = pd.DataFrame(list(expense_transfers.values('date', 'amount')))
    income_data = pd.DataFrame(list(income_transfers.values('date', 'amount')))
    expense_data['date'] = pd.to_datetime(expense_data['date'])
    income_data['date'] = pd.to_datetime(income_data['date'])

    expense_data['Days'] = (expense_data['date'] - expense_data['date'].min()).dt.days
    income_data['Days'] = (income_data['date'] - income_data['date'].min()).dt.days

    last_date = max(expense_data['date'].max(), income_data['date'].max())

    expense_forecast = forecast_next_6_months(expense_model, expense_scaler, last_date, expense_data['date'].min())
    income_forecast = forecast_next_6_months(income_model, income_scaler, last_date, income_data['date'].min())

    income_forecast.set_index('Data operacji', inplace=True)
    expense_forecast.set_index('Data operacji', inplace=True)

    net_forecast = income_forecast['Predicted Amount'] + expense_forecast['Predicted Amount']

    print("Net savings forecast data:")
    print(net_forecast)

    net_forecast_df = pd.DataFrame({
        'Data operacji': net_forecast.index,
        'Prognozowany bilans (przychody - wydatki)': net_forecast.values
    })

    response_data = net_forecast_df.to_dict(orient='records')
    return Response(response_data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def predict_and_allocate_savings(request):
    user_accounts = Account.objects.filter(user=request.user)
    user_transfers = Transfer.objects.filter(account_id__in=user_accounts, is_deleted=False)

    expense_categories = Category.objects.filter(category_type='expense').values_list('id', flat=True)
    income_categories = Category.objects.filter(category_type='income').values_list('id', flat=True)

    expense_transfers = user_transfers.filter(category_id__in=expense_categories)
    income_transfers = user_transfers.filter(category_id__in=income_categories)

    expense_data = pd.DataFrame(list(expense_transfers.values('date', 'amount')))
    income_data = pd.DataFrame(list(income_transfers.values('date', 'amount')))
    expense_data['date'] = pd.to_datetime(expense_data['date'])
    income_data['date'] = pd.to_datetime(income_data['date'])

    expense_data['Days'] = (expense_data['date'] - expense_data['date'].min()).dt.days
    income_data['Days'] = (income_data['date'] - income_data['date'].min()).dt.days

    last_date = max(expense_data['date'].max(), income_data['date'].max())

    expense_forecast = forecast_next_6_months(expense_model, expense_scaler, last_date, expense_data['date'].min())
    income_forecast = forecast_next_6_months(income_model, income_scaler, last_date, income_data['date'].min())

    income_forecast.set_index('Data operacji', inplace=True)
    expense_forecast.set_index('Data operacji', inplace=True)

    net_forecast = income_forecast['Predicted Amount'] - expense_forecast['Predicted Amount']

    user_goals = Goal.objects.filter(user_id=request.user.id, is_deleted=False)
    if not user_goals.exists():
        print("No goals found for user.")
        return Response({"message": "No goals found for this user"}, status=400)

    total_priority = sum(goal.priority for goal in user_goals)
    if total_priority == 0:
        print("Total priority is zero. Cannot allocate savings.")
        return Response({"message": "Total priority is zero. Cannot allocate savings."}, status=400)

    goal_allocation_data = {
        goal.id: {
            'goal_name': goal.goal_name,
            'goal_icon': goal.goal_icon,
            'target_amount': float(goal.target_amount),
            'current_amount': float(goal.current_amount),
            'allocated_amount': 0,
            'estimated_end_date': "In Progress",
            'monthly_allocations': [],
            'unachievable': False,
            'missing_amount': 0
        }
        for goal in user_goals
    }

    remaining_goals = [goal for goal in user_goals if goal.current_amount < goal.target_amount]

    for month, net_saving in net_forecast.items():
        if not remaining_goals:
            print("All goals are fully funded or unachievable. Ending allocation process.")
            break

        print(f"\n==== Allocating for Month: {month.strftime('%Y-%m')} ====")
        print(f"Net Saving Available: {net_saving}")

        monthly_allocation = Decimal(net_saving)
        total_priority = sum(goal.priority for goal in remaining_goals)

        for goal in remaining_goals[:]:
            remaining_amount = goal.target_amount - goal.current_amount
            if remaining_amount <= 0:
                continue

            allocated_amount = Decimal(goal.priority / total_priority) * monthly_allocation
            allocated_amount = min(allocated_amount, remaining_amount)

            goal.current_amount += allocated_amount
            goal_allocation_data[goal.id]['allocated_amount'] += float(allocated_amount)
            goal_allocation_data[goal.id]['current_amount'] = float(goal.current_amount)

            goal_allocation_data[goal.id]['monthly_allocations'].append({
                'month': month.strftime('%Y-%m'),
                'amount': float(allocated_amount)
            })

            print(f"Allocated {allocated_amount} to '{goal.goal_name}' (Priority: {goal.priority})")
            print(f" - New Current Amount: {goal.current_amount} / Target: {goal.target_amount}")

            if goal.current_amount >= goal.target_amount:
                goal_allocation_data[goal.id]['estimated_end_date'] = month.strftime('%Y-%m-%d')
                remaining_goals.remove(goal)

    for goal in remaining_goals:
        if goal.current_amount < goal.target_amount:
            goal_allocation_data[goal.id]['estimated_end_date'] = "Unachievable"
            goal_allocation_data[goal.id]['unachievable'] = True
            goal_allocation_data[goal.id]['missing_amount'] = float(goal.target_amount - goal.current_amount)
            print(f"Goal '{goal.goal_name}' is marked as unachievable within the next 6 months.")
            print(f"Missing amount for '{goal.goal_name}': {goal_allocation_data[goal.id]['missing_amount']}")

    response_data = list(goal_allocation_data.values())

    return Response(response_data)
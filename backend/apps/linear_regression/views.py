from decimal import Decimal
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
import pandas as pd
from apps.accounts.models import Account
from apps.categories.models import Category
from apps.goals.models import Goal
from apps.transfers.models import Transfer


def train_model(data):
    X = data[['Days']]
    y = data['amount']

    X_train, _, y_train, _ = train_test_split(X, y, test_size=0.2, random_state=42)
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)

    model = LinearRegression()
    model.fit(X_train_scaled, y_train)

    return model, scaler


def forecast_next_6_months(model, scaler, start_date, min_date, is_expense=False):
    future_dates = pd.date_range(start=start_date, periods=6, freq='ME')
    future_days = (future_dates - min_date).days.values.reshape(-1, 1)
    future_days_df = pd.DataFrame(future_days, columns=['Days'])

    future_days_scaled = scaler.transform(future_days_df)
    future_predictions = model.predict(future_days_scaled)

    if is_expense:
        future_predictions = -abs(future_predictions)

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

    if data.empty:
        return Response({"error": "No expense data available."}, status=400)

    last_date = data['date'].max()
    model, scaler = train_model(data)
    expense_forecast = forecast_next_6_months(model, scaler, last_date, data['date'].min(), is_expense=True)

    response_data = expense_forecast.to_dict(orient='records')
    return Response(response_data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def predict_income(request):
    user_accounts = Account.objects.filter(user=request.user)
    user_transfers = Transfer.objects.filter(account_id__in=user_accounts, is_deleted=False)

    income_categories = Category.objects.filter(category_type='income').values_list('id', flat=True)
    income_transfers = user_transfers.filter(category_id__in=income_categories)

    data = pd.DataFrame(list(income_transfers.values('date', 'amount')))
    data['date'] = pd.to_datetime(data['date'])
    data['Days'] = (data['date'] - data['date'].min()).dt.days

    if data.empty:
        return Response({"error": "No income data available."}, status=400)

    last_date = data['date'].max()
    model, scaler = train_model(data)
    income_forecast = forecast_next_6_months(model, scaler, last_date, data['date'].min())

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

    if expense_data.empty or income_data.empty:
        return Response({"error": "Insufficient data for net savings prediction."}, status=400)

    last_date = max(expense_data['date'].max(), income_data['date'].max())

    expense_model, expense_scaler = train_model(expense_data)
    income_model, income_scaler = train_model(income_data)

    expense_forecast = forecast_next_6_months(expense_model, expense_scaler, last_date, expense_data['date'].min(),
                                              is_expense=True)
    income_forecast = forecast_next_6_months(income_model, income_scaler, last_date, income_data['date'].min())

    income_forecast.set_index('Data operacji', inplace=True)
    expense_forecast.set_index('Data operacji', inplace=True)

    net_forecast = income_forecast['Predicted Amount'] + expense_forecast['Predicted Amount']

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

    if expense_data.empty or income_data.empty:
        return Response({"error": "Insufficient data for prediction."}, status=400)

    last_date = max(expense_data['date'].max(), income_data['date'].max())
    expense_model, expense_scaler = train_model(expense_data)
    income_model, income_scaler = train_model(income_data)

    expense_forecast = forecast_next_6_months(expense_model, expense_scaler, last_date, expense_data['date'].min(),
                                              is_expense=True)
    income_forecast = forecast_next_6_months(income_model, income_scaler, last_date, income_data['date'].min())

    income_forecast.set_index('Data operacji', inplace=True)
    expense_forecast.set_index('Data operacji', inplace=True)

    net_forecast = income_forecast['Predicted Amount'] + expense_forecast['Predicted Amount']

    user_goals = Goal.objects.filter(user_id=request.user.id, is_deleted=False, status="active")
    if not user_goals.exists():
        return Response({"message": "No active goals found for this user"}, status=400)

    total_priority = sum(goal.priority for goal in user_goals)
    if total_priority == 0:
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
            break

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

            if goal.current_amount >= goal.target_amount:
                goal_allocation_data[goal.id]['estimated_end_date'] = month.strftime('%Y-%m-%d')
                remaining_goals.remove(goal)

    for goal in remaining_goals:
        if goal.current_amount < goal.target_amount:
            goal_allocation_data[goal.id]['estimated_end_date'] = "Unachievable"
            goal_allocation_data[goal.id]['unachievable'] = True
            goal_allocation_data[goal.id]['missing_amount'] = float(goal.target_amount - goal.current_amount)

    response_data = list(goal_allocation_data.values())
    return Response(response_data)

import joblib
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
import matplotlib.pyplot as plt

data = pd.read_csv('data.csv')

data['Data operacji'] = pd.to_datetime(data['Data operacji'], format='%Y-%m-%d')
data['Days'] = (data['Data operacji'] - data['Data operacji'].min()).dt.days

income_data = data[data['Kwota'] > 0]
expense_data = data[data['Kwota'] < 0]


def train_model(data, model_filename, scaler_filename):
    X = data[['Days']]
    y = data['Kwota']

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    model = LinearRegression()
    model.fit(X_train_scaled, y_train)

    y_pred = model.predict(X_test_scaled)

    results_df = pd.DataFrame({
        'Data operacji': X_test['Days'].apply(lambda x: data['Data operacji'].min() + pd.Timedelta(days=x)),
        'Rzeczywiste kwoty': y_test.values,
        'Przewidywane kwoty': y_pred
    })
    results_df['Miesiąc'] = results_df['Data operacji'].dt.to_period('M')

    monthly_real = results_df.groupby('Miesiąc')['Rzeczywiste kwoty'].sum()
    monthly_predicted = results_df.groupby('Miesiąc')['Przewidywane kwoty'].sum()

    joblib.dump(model, model_filename)
    joblib.dump(scaler, scaler_filename)

    return model, scaler, monthly_real, monthly_predicted, results_df


income_model, income_scaler, monthly_income_real, monthly_income_predicted, income_results_df = train_model(
    income_data, 'model_regresji_liniowej_income.pkl', 'scaler_income.pkl'
)
expense_model, expense_scaler, monthly_expense_real, monthly_expense_predicted, expense_results_df = train_model(
    expense_data, 'model_regresji_liniowej_expense.pkl', 'scaler_expense.pkl'
)

print("Model i skaler dla przychodów oraz wydatków zostały zapisane.")

income_comparison = pd.DataFrame({
    'Rzeczywiste przychody': monthly_income_real,
    'Przewidywane przychody': monthly_income_predicted
})
print("\nRzeczywiste i przewidywane miesięczne przychody:")
print(income_comparison)

plt.figure(figsize=(10, 6))
monthly_income_predicted.plot(kind='bar', color='skyblue', label='Przewidywane przychody')
plt.title('Przewidywane miesięczne przychody')
plt.xlabel('Miesiąc')
plt.ylabel('Kwota przychodu')
plt.legend()
plt.show()

plt.figure(figsize=(10, 6))
plt.scatter(income_results_df['Data operacji'], income_results_df['Rzeczywiste kwoty'], color='black', alpha=0.5,
            label='Rzeczywiste przychody')
income_sorted = income_results_df.sort_values(by='Data operacji')
plt.plot(income_sorted['Data operacji'], income_sorted['Przewidywane kwoty'], color='blue', linewidth=2,
         label='Linia regresji - przychody')
plt.title('Regresja liniowa: Rzeczywiste vs Przewidywane przychody dzienne')
plt.xlabel('Data operacji')
plt.ylabel('Kwota przychodu')
plt.legend()
plt.show()

expense_comparison = pd.DataFrame({
    'Rzeczywiste wydatki': monthly_expense_real,
    'Przewidywane wydatki': monthly_expense_predicted
})
print("\nRzeczywiste i przewidywane miesięczne wydatki:")
print(expense_comparison)

plt.figure(figsize=(10, 6))
monthly_expense_predicted.plot(kind='bar', color='salmon', label='Przewidywane wydatki')
plt.title('Przewidywane miesięczne wydatki')
plt.xlabel('Miesiąc')
plt.ylabel('Kwota wydatku')
plt.legend()
plt.show()

plt.figure(figsize=(10, 6))
plt.scatter(expense_results_df['Data operacji'], expense_results_df['Rzeczywiste kwoty'], color='black', alpha=0.5,
            label='Rzeczywiste wydatki')
expense_sorted = expense_results_df.sort_values(by='Data operacji')
plt.plot(expense_sorted['Data operacji'], expense_sorted['Przewidywane kwoty'], color='red', linewidth=2,
         label='Linia regresji - wydatki')
plt.title('Regresja liniowa: Rzeczywiste vs Przewidywane wydatki dzienne')
plt.xlabel('Data operacji')
plt.ylabel('Kwota wydatku')
plt.legend()
plt.show()


def forecast_next_6_months(model, scaler, start_date):
    future_dates = pd.date_range(start=start_date, periods=6, freq='ME')
    future_days = (future_dates - data['Data operacji'].min()).days.values.reshape(-1, 1)
    future_days_df = pd.DataFrame(future_days, columns=['Days'])
    future_days_scaled = scaler.transform(future_days_df)

    future_predictions = model.predict(future_days_scaled)
    forecast_df = pd.DataFrame({
        'Data operacji': future_dates,
        'Przewidywana kwota': future_predictions
    })
    return forecast_df


last_date = data['Data operacji'].max()
income_forecast = forecast_next_6_months(income_model, income_scaler, last_date)
expense_forecast = forecast_next_6_months(expense_model, expense_scaler, last_date)

print("\nPrognoza miesięcznych przychodów na następne 6 miesięcy:")
print(income_forecast)

print("\nPrognoza miesięcznych wydatków na następne 6 miesięcy:")
print(expense_forecast)

net_forecast = income_forecast['Przewidywana kwota'] + expense_forecast['Przewidywana kwota']

net_forecast_df = pd.DataFrame({
    'Data operacji': income_forecast['Data operacji'],
    'Prognozowany bilans (przychody - wydatki)': net_forecast
})

print("\nPrognoza bilansu (przychody - wydatki) na następne 6 miesięcy:")
print(net_forecast_df)

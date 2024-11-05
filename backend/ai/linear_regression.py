import joblib
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, mean_squared_error
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler

df = pd.read_csv('aug_personal_transactions_with_UserId.csv')
df['Date'] = pd.to_datetime(df['Date'])

df['Amount'] = np.where(df['Transaction Type'] == 'credit', df['Amount'], -df['Amount'])

daily_net_income = df.groupby('Date')['Amount'].sum().reset_index()
daily_net_income.columns = ['Date', 'Net Income']

daily_net_income['Cumulative Savings'] = daily_net_income['Net Income'].cumsum()

daily_net_income['Month'] = daily_net_income['Date'].dt.month
daily_net_income['DayOfYear'] = daily_net_income['Date'].dt.dayofyear

daily_net_income['Target_Savings'] = daily_net_income['Cumulative Savings'].shift(-1)
daily_net_income = daily_net_income.dropna()

X = daily_net_income[['Month', 'DayOfYear', 'Cumulative Savings']]
y = daily_net_income['Target_Savings']

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

model = LinearRegression()
model.fit(X_train, y_train)

y_pred = model.predict(X_test)

mae = mean_absolute_error(y_test, y_pred)
mse = mean_squared_error(y_test, y_pred)
rmse = np.sqrt(mse)

print("Evaluation Metrics:")
print(f"Mean Absolute Error (MAE): {mae}")
print(f"Mean Squared Error (MSE): {mse}")
print(f"Root Mean Squared Error (RMSE): {rmse}")

comparison_df = pd.DataFrame({'Date': X_test.index, 'Actual Savings': y_test.values, 'Predicted Savings': y_pred})
print("\nSample Comparison (Actual vs Predicted Savings):")
print(comparison_df.head(10))

plt.figure(figsize=(10, 6))
plt.plot(y_test.values, label='Actual Savings')
plt.plot(y_pred, label='Predicted Savings', linestyle='--')
plt.xlabel('Sample')
plt.ylabel('Cumulative Savings')
plt.title('Actual vs. Predicted Cumulative Savings')
plt.legend()
plt.show()

plt.figure(figsize=(8, 6))
plt.scatter(daily_net_income['Cumulative Savings'], daily_net_income['Target_Savings'], color='black', alpha=0.6)
plt.plot(daily_net_income['Cumulative Savings'], model.predict(X), color='blue', linewidth=2)
plt.xlabel('Cumulative Savings (Previous Day)')
plt.ylabel('Target Savings (Next Day)')
plt.title('Linear Regression: Cumulative Savings vs. Target Savings')
plt.show()

X_test_with_dates = X_test.copy()
X_test_with_dates['Date'] = daily_net_income['Date'].iloc[X_test.index]
X_test_with_dates['Actual Savings'] = y_test.values
X_test_with_dates['Predicted Savings'] = y_pred
X_test_with_dates['Month'] = X_test_with_dates['Date'].dt.to_period('M')
monthly_actual_savings = X_test_with_dates.groupby('Month')['Actual Savings'].sum().reset_index()
monthly_predicted_savings = X_test_with_dates.groupby('Month')['Predicted Savings'].sum().reset_index()

plt.figure(figsize=(10, 6))
plt.plot(monthly_actual_savings['Month'].dt.to_timestamp(), monthly_actual_savings['Actual Savings'], marker='o',
         label='Actual Monthly Savings')
plt.plot(monthly_predicted_savings['Month'].dt.to_timestamp(), monthly_predicted_savings['Predicted Savings'],
         marker='x', linestyle='--', label='Predicted Monthly Savings')
plt.xlabel('Date')
plt.ylabel('Monthly Savings')
plt.title('Actual vs Predicted Monthly Savings (Test Set)')
plt.legend()
plt.grid()
plt.show()

future_dates = []
future_savings = []
last_date = daily_net_income['Date'].iloc[-1]
last_savings = daily_net_income['Cumulative Savings'].iloc[-1]

for day in range(1, 366):
    next_date = last_date + pd.Timedelta(days=1)
    month = next_date.month
    day_of_year = next_date.dayofyear

    features = pd.DataFrame([[month, day_of_year, last_savings]], columns=['Month', 'DayOfYear', 'Cumulative Savings'])
    predicted_savings = model.predict(features)[0]

    future_dates.append(next_date)
    future_savings.append(predicted_savings)
    last_savings = predicted_savings
    last_date = next_date

predicted_future_df = pd.DataFrame({'Date': future_dates, 'Predicted Daily Savings': future_savings})

predicted_future_df['Month'] = predicted_future_df['Date'].dt.to_period('M')
monthly_predicted_future_savings = predicted_future_df.groupby('Month')['Predicted Daily Savings'].sum().reset_index()

print("\nPredicted Savings for the Next 12 Months:")
print(monthly_predicted_future_savings.head(12))

plt.figure(figsize=(10, 6))
plt.plot(monthly_predicted_future_savings['Month'].dt.to_timestamp(),
         monthly_predicted_future_savings['Predicted Daily Savings'], marker='o', linestyle='-')
plt.xlabel('Date')
plt.ylabel('Predicted Monthly Savings')
plt.title('Predicted Monthly Savings for the Next 12 Months')
plt.grid()
plt.show()

joblib.dump(model, 'model_regresji_liniowej.pkl')
joblib.dump(scaler, 'scaler.pkl')

print("Model i skaler zostały zapisane.")
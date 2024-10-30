# savings_prediction.py

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, mean_squared_error
import matplotlib.pyplot as plt

# Load the CSV file
df = pd.read_csv('aug_personal_transactions_with_UserId.csv')

# Convert Date to datetime format
df['Date'] = pd.to_datetime(df['Date'])

# Assign positive for credits, negative for debits
df['Amount'] = np.where(df['Transaction Type'] == 'credit', df['Amount'], -df['Amount'])

# Group by Date to get daily net income
daily_net_income = df.groupby('Date')['Amount'].sum().reset_index()
daily_net_income.columns = ['Date', 'Net Income']

# Calculate cumulative savings
daily_net_income['Cumulative Savings'] = daily_net_income['Net Income'].cumsum()

# Extract month and day of the year as features
daily_net_income['Month'] = daily_net_income['Date'].dt.month
daily_net_income['DayOfYear'] = daily_net_income['Date'].dt.dayofyear

# Shift Cumulative Savings to predict future savings
daily_net_income['Target_Savings'] = daily_net_income['Cumulative Savings'].shift(-1)

# Drop the last row as it won't have a target
daily_net_income = daily_net_income.dropna()

# Define features and target
X = daily_net_income[['Month', 'DayOfYear', 'Cumulative Savings']]
y = daily_net_income['Target_Savings']

# Split data into training and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Initialize and train the model
model = LinearRegression()
model.fit(X_train, y_train)

# Make predictions on the test set
y_pred = model.predict(X_test)

# Calculate evaluation metrics
mae = mean_absolute_error(y_test, y_pred)
mse = mean_squared_error(y_test, y_pred)
rmse = np.sqrt(mse)

# Print metrics to the console
print("Evaluation Metrics:")
print(f"Mean Absolute Error (MAE): {mae}")
print(f"Mean Squared Error (MSE): {mse}")
print(f"Root Mean Squared Error (RMSE): {rmse}")

# Print sample data for comparison
print("\nSample Comparison (Actual vs Predicted Savings):")
comparison_df = pd.DataFrame({'Actual Savings': y_test.values, 'Predicted Savings': y_pred})
print(comparison_df.head(10))

# Plot actual vs predicted cumulative savings
plt.figure(figsize=(10, 6))
plt.plot(y_test.values, label='Actual Savings')
plt.plot(y_pred, label='Predicted Savings', linestyle='--')
plt.xlabel('Sample')
plt.ylabel('Cumulative Savings')
plt.title('Actual vs. Predicted Cumulative Savings')
plt.legend()
plt.show()

# Scatter plot with regression line
plt.figure(figsize=(8, 6))
plt.scatter(daily_net_income['Cumulative Savings'], daily_net_income['Target_Savings'], color='black', alpha=0.6)
plt.plot(daily_net_income['Cumulative Savings'], model.predict(X), color='blue', linewidth=2)
plt.xlabel('Cumulative Savings (Previous Day)')
plt.ylabel('Target Savings (Next Day)')
plt.title('Linear Regression: Cumulative Savings vs. Target Savings')
plt.show()

# --- Przewidywanie oszczędności na kolejne 12 miesięcy ---

# Pobranie ostatniej dostępnej daty i skumulowanych oszczędności
last_date = daily_net_income['Date'].iloc[-1]
last_savings = daily_net_income['Cumulative Savings'].iloc[-1]

# Tworzenie listy do przechowywania prognoz
future_dates = []
future_savings = []

# Generowanie prognoz dla kolejnych 12 miesięcy
for month in range(1, 73):
    next_date = last_date + pd.DateOffset(months=month)
    month_num = next_date.month
    day_of_year = next_date.timetuple().tm_yday

    # Tworzenie wejściowego wektora cech
    features = pd.DataFrame([[month_num, day_of_year, last_savings]], columns=['Month', 'DayOfYear', 'Cumulative Savings'])
    predicted_savings = model.predict(features)[0]

    # Aktualizacja oszczędności i dat
    future_dates.append(next_date)
    future_savings.append(predicted_savings)
    last_savings = predicted_savings  # Skumulowane oszczędności na następny miesiąc

# Wyświetlanie przewidywanych oszczędności
future_df = pd.DataFrame({'Date': future_dates, 'Predicted Savings': future_savings})
print("\nPredicted Savings for the Next 12 Months:")
print(future_df)

# Wizualizacja prognoz na kolejne 12 miesięcy
plt.figure(figsize=(10, 6))
plt.plot(future_df['Date'], future_df['Predicted Savings'], marker='o', linestyle='-', color='green')
plt.xlabel('Date')
plt.ylabel('Predicted Cumulative Savings')
plt.title('Predicted Cumulative Savings for the Next 12 Months')
plt.grid()
plt.show()
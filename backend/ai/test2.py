import pandas as pd
import matplotlib.pyplot as plt

# Load the data
df = pd.read_csv('aug_personal_transactions_with_UserId.csv')

# Ensure the 'Date' column is in datetime format
df['Date'] = pd.to_datetime(df['Date'])

# Separate data for debit and credit transactions
debit_df = df[df['Transaction Type'] == 'debit']
credit_df = df[df['Transaction Type'] == 'credit']

# Group by date and sum the amounts for each transaction type
daily_debit = debit_df.groupby('Date')['Amount'].sum()
daily_credit = credit_df.groupby('Date')['Amount'].sum()

# Plotting in the specified style
plt.figure(figsize=(10, 6))
plt.scatter(daily_debit.index, daily_debit.values, color='red', label='Debit', alpha=0.8)
plt.scatter(daily_credit.index, daily_credit.values, color='green', label='Credit', alpha=0.8)
plt.title("Daily Spending and Income Over Time", color='white')
plt.xlabel("Date", color='white')
plt.ylabel("Total Amount", color='white')
plt.legend()
plt.grid(False)  # Remove grid if not desired
plt.show()

import pandas as pd
from datetime import datetime

csv_file_path = 'data.csv'
data = pd.read_csv(csv_file_path)

data = data.rename(columns={
    'Data operacji': 'date',
    'Typ transakcji': 'transfer_name',
    'Kwota': 'amount'
})

data['is_deleted'] = 0
data['is_regular'] = 0
data['account_id'] = 1
data['description'] = 'Automated Entry'

data['category_id'] = data['amount'].apply(lambda x: 1 if x < 0 else 2)

data['amount'] = data['amount'].abs()

sql_statements = []
for _, row in data.iterrows():
    date_str = row['date']
    if isinstance(date_str, str):
        date_str = datetime.strptime(date_str, '%Y-%m-%d').strftime('%Y-%m-%d %H:%M:%S')
    else:
        date_str = row['date'].strftime('%Y-%m-%d %H:%M:%S')

    sql = f"""
    INSERT INTO transfers (transfer_name, amount, description, date, is_deleted, is_regular, account_id, category_id)
    VALUES ('{row['transfer_name']}', {row['amount']}, '{row['description']}', '{date_str}', 
            {row['is_deleted']}, {row['is_regular']}, {row['account_id']}, {row['category_id']});
    """
    sql_statements.append(sql.strip())

with open('insert_transfers.sql', 'w', encoding='utf-8') as f:
    for statement in sql_statements:
        f.write(statement + '\n')

print("SQL insert statements have been generated and saved to 'insert_transfers.sql'")

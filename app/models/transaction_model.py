from app.config.db_config import create_connection

class TransactionModel:
    def __init__(self):
        self.connection = create_connection()

    def create_table(self):
        cursor = self.connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS transactions (
                transaction_id INT PRIMARY KEY AUTO_INCREMENT,
                amount FLOAT NOT NULL,
                account_id INT NOT NULL,
                transaction_date DATETIME NOT NULL,
                description VARCHAR(255),
                category_id INT NOT NULL,
                user_id INT NOT NULL,
                FOREIGN KEY (account_id) REFERENCES accounts(account_id),
                FOREIGN KEY (category_id) REFERENCES categories(category_id),
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        ''')
        self.connection.commit()

    def add_transaction(self, amount, account_id, transaction_date, description, category_id, user_id):
        cursor = self.connection.cursor()
        cursor.execute('''
            INSERT INTO transactions (amount, account_id, transaction_date, description, category_id, user_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        ''', (amount, account_id, transaction_date, description, category_id, user_id))
        self.connection.commit()

    def get_user_transactions(self, user_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('''
            SELECT t.* FROM transactions t
            JOIN accounts a ON t.account_id = a.account_id
            WHERE t.user_id = %s
        ''', (user_id,))
        return cursor.fetchall()

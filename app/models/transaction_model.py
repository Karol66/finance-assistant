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
                is_deleted BOOLEAN DEFAULT FALSE, 
                FOREIGN KEY (account_id) REFERENCES accounts(account_id),
                FOREIGN KEY (category_id) REFERENCES categories(category_id),
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        ''')
        self.connection.commit()

    def add_transaction(self, user_id, amount, account_id, transaction_date, description, category_id):
        cursor = self.connection.cursor()
        cursor.execute('''
            INSERT INTO transactions (user_id, amount, account_id, transaction_date, description, category_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        ''', (user_id, amount, account_id, transaction_date, description, category_id))
        self.connection.commit()

    def get_user_transactions(self, user_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('''
            SELECT t.* FROM transactions t
            JOIN accounts a ON t.account_id = a.account_id
            WHERE t.user_id = %s AND t.is_deleted = FALSE
        ''', (user_id,))
        return cursor.fetchall()

    def get_transaction_by_id(self, transaction_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('SELECT * FROM transactions WHERE transaction_id = %s AND is_deleted = FALSE', (transaction_id,))
        return cursor.fetchone()

    def update_transaction(self, transaction_id, user_id, amount, account_id, transaction_date, description, category_id):
        cursor = self.connection.cursor()
        cursor.execute('''
            UPDATE transactions 
            SET amount = %s, account_id = %s, transaction_date = %s, description = %s, category_id = %s
            WHERE transaction_id = %s AND user_id = %s AND is_deleted = FALSE
        ''', (amount, account_id, transaction_date, description, category_id, transaction_id, user_id))
        self.connection.commit()

    def delete_transaction(self, transaction_id, user_id):
        cursor = self.connection.cursor()
        cursor.execute('''
            UPDATE transactions 
            SET is_deleted = TRUE
            WHERE transaction_id = %s AND user_id = %s
        ''', (transaction_id, user_id))
        self.connection.commit()

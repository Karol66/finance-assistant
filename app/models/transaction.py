from app.config.db_config import create_connection

class TransactionModel:
    def __init__(self):
        self.connection = create_connection()

    def create_table(self):
        cursor = self.connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS transactions (
                transaction_id INT AUTO_INCREMENT PRIMARY KEY,
                account_id INT,
                user_id INT,
                amount FLOAT NOT NULL,
                transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                category_id INT,
                description VARCHAR(255),
                FOREIGN KEY (account_id) REFERENCES accounts(account_id),
                FOREIGN KEY (user_id) REFERENCES users(user_id),
                FOREIGN KEY (category_id) REFERENCES categories(category_id)
            )
        ''')
        self.connection.commit()
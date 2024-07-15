from app.config.db_config import create_connection

class AccountModel:
    def __init__(self):
        self.connection = create_connection()

    def create_table(self):
        cursor = self.connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS accounts (
                account_id INT PRIMARY KEY AUTO_INCREMENT,
                user_id INT,
                account_name VARCHAR(100) NOT NULL,
                account_type VARCHAR(100) NOT NULL,
                balance FLOAT NOT NULL,
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        ''')
        self.connection.commit()

    def add_account(self, user_id, account_name, account_type, balance):
        cursor = self.connection.cursor()
        cursor.execute('''
            INSERT INTO accounts (user_id, account_name, account_type, balance)
            VALUES (%s, %s, %s, %s)
        ''', (user_id, account_name, account_type, balance))
        self.connection.commit()

    def get_accounts_by_user_id(self, user_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('SELECT * FROM accounts WHERE user_id = %s', (user_id,))
        return cursor.fetchall()

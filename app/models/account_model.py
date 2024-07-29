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
                account_color VARCHAR(50) NOT NULL,
                account_icon VARCHAR(50) NOT NULL,
                card_id INT,
                include_in_total INT(1) NOT NULL,
                FOREIGN KEY (user_id) REFERENCES users(user_id),
                FOREIGN KEY (card_id) REFERENCES cards(card_id)
            )
        ''')
        self.connection.commit()

    def add_account(self, user_id, account_name, account_type, balance, account_color, account_icon, card_id, include_in_total):
        cursor = self.connection.cursor()
        cursor.execute('''
            INSERT INTO accounts (user_id, account_name, account_type, balance, account_color, account_icon, card_id, include_in_total)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ''', (user_id, account_name, account_type, balance, account_color, account_icon, card_id, include_in_total))
        self.connection.commit()

    def get_accounts_by_user_id(self, user_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('SELECT * FROM accounts WHERE user_id = %s', (user_id,))
        return cursor.fetchall()

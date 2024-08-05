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
                is_deleted BOOLEAN DEFAULT FALSE,
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

    def get_user_accounts(self, user_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('SELECT * FROM accounts WHERE user_id = %s', (user_id,))
        return cursor.fetchall()

    def get_account_by_id(self, account_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('SELECT * FROM accounts WHERE account_id = %s', (account_id,))
        return cursor.fetchone()

    def update_account(self, account_id, user_id, account_name, account_type, balance, account_color, account_icon, card_id, include_in_total):
        cursor = self.connection.cursor()
        cursor.execute('''
            UPDATE accounts
            SET account_name = %s, account_type = %s, balence = %s, account_color = %s, account_icon = %s, card_id = %s, include_in_total = %s 
            WHERE account_id = %s AND user_id = %s AND is_deleted = FALSE
        ''', (account_name, account_type, account_color, account_icon, card_id, include_in_total, account_id, user_id))
        self.connection.commit()

    def delete_account(self, account_id, user_id):
        cursor = self.connection.cursor()
        cursor.execute('''
            UPDATE accounts
            SET is_deleted = TRUE 
            WHERE account_id = %s AND user_id = %s
        ''', (account_id, user_id))
        self.connection.commit()

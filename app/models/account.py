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
                FOREIGN KEY (user_id) REFERENCES users (user_id)
            )
        ''')
        self.connection.commit()
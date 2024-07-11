import hashlib
from app.config.db_config import create_connection


class UserModel:
    def __init__(self):
        self.connection = create_connection()

    def create_table(self):
        cursor = self.connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                email VARCHAR(100) NOT NULL UNIQUE,
                password VARCHAR(100) NOT NULL
            )
        ''')
        self.connection.commit()

    def add_user(self, email, password):
        hashed_password = hashlib.sha256(password.encode()).hexdigest()
        cursor = self.connection.cursor()
        cursor.execute('''
            INSERT INTO users (email, password) VALUES (%s, %s)
        ''', (email, hashed_password))
        self.connection.commit()

    def get_user_by_email(self, email):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('''
            SELECT * FROM users WHERE email = %s
        ''', (email,))
        return cursor.fetchone()

    def validate_user(self, email, password):
        user = self.get_user_by_email(email)
        if user:
            hashed_password = hashlib.sha256(password.encode()).hexdigest()
            if user['password'] == hashed_password:
                return True
        return False

    # def update_user_password(self, email, new_password):
    #     hashed_password = hashlib.sha256(new_password.encode()).hexdigest()
    #     cursor = self.connection.cursor()
    #     cursor.execute('''
    #         UPDATE users SET password = %s WHERE email = %s
    #     ''', (hashed_password, email))
    #     self.connection.commit()
    #
    # def delete_user(self, email):
    #     cursor = self.conn.cursor()
    #     cursor.execute('''
    #         DELETE FROM users WHERE email = %s
    #     ''', (email,))
    #     self.connection.commit()

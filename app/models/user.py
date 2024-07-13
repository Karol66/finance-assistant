import hashlib
from app.config.db_config import create_connection


class UserModel:
    def __init__(self):
        self.connection = create_connection()

    def create_table(self):
        cursor = self.connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                user_id INT AUTO_INCREMENT PRIMARY KEY,
                email VARCHAR(100) NOT NULL UNIQUE,
                username VARCHAR(100) NOT NULL UNIQUE,
                password VARCHAR(100) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        self.connection.commit()

    def add_user(self, email, username, password):
        hashed_password = hashlib.sha256(password.encode()).hexdigest()
        cursor = self.connection.cursor()
        cursor.execute('''
            INSERT INTO users (email, username, password) VALUES (%s, %s, %s)
        ''', (email, username, hashed_password))
        self.connection.commit()

    def get_user_by_email(self, email):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('''
            SELECT * FROM users WHERE email = %s
        ''', (email,))
        return cursor.fetchone()

    def get_user_by_username(self, username):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('''
            SELECT * FROM users WHERE username = %s
        ''', (username,))
        return cursor.fetchone()

    def get_user_by_email_or_username(self, identifier):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('''
            SELECT * FROM users WHERE email = %s OR username = %s
        ''', (identifier, identifier))
        return cursor.fetchone()

    def validate_user(self, identifier, password):
        user = self.get_user_by_email_or_username(identifier)
        if user:
            hashed_password = hashlib.sha256(password.encode()).hexdigest()
            if user['password'] == hashed_password:
                return True
        return False

from app.config.db_config import create_connection

class PaymentModel:
    def __init__(self):
        self.connection = create_connection()

    def create_table(self):
        cursor = self.connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS transfers (
                transfer_id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT,
                amount FLOAT NOT NULL,
                payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                description VARCHAR(255),
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        ''')
        self.connection.commit()

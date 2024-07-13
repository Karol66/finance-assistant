from app.config.db_config import create_connection

class StatisticModel:
    def __init__(self):
        self.connection = create_connection()

    def create_table(self):
        cursor = self.connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS statistics (
                statistic_id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT,
                statistic_type VARCHAR(50) NOT NULL,
                value FLOAT NOT NULL,
                calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        ''')
        self.connection.commit()
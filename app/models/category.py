from app.config.db_config import create_connection

class CategoryModel:
    def __init__(self):
        self.connection = create_connection()

    def create_table(self):
        cursor = self.connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS categories (
                category_id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT,
                category_name VARCHAR(100) NOT NULL,
                category_type VARCHAR(50) NOT NULL,
                planned_expanses VARCHAR(50) NOT NULL,
                category_color VARCHAR(50) NOT NULL,
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        ''')
        self.connection.commit()
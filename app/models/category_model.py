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
                planned_expenses VARCHAR(50) NOT NULL,
                category_color VARCHAR(50) NOT NULL,
                category_icon VARCHAR(50) NOT NULL,
                is_deleted BOOLEAN DEFAULT FALSE, 
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        ''')
        self.connection.commit()

    def add_category(self, user_id, category_name, category_type, planned_expenses, category_color, category_icon):
        cursor = self.connection.cursor()
        cursor.execute('''
            INSERT INTO categories (user_id, category_name, category_type, planned_expenses, category_color, category_icon)
            VALUES (%s, %s, %s, %s, %s, %s)
        ''', (user_id, category_name, category_type, planned_expenses, category_color, category_icon))
        self.connection.commit()

    def get_user_categories(self, user_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('SELECT * FROM categories WHERE user_id = %s AND is_deleted = FALSE', (user_id,))
        return cursor.fetchall()

    def get_category_by_id(self, category_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('SELECT * FROM categories WHERE category_id = %s AND is_deleted = FALSE', (category_id,))
        return cursor.fetchone()

    def update_category(self, category_id, user_id, category_name, category_type, planned_expenses, category_color, category_icon):
        cursor = self.connection.cursor()
        cursor.execute('''
            UPDATE categories 
            SET category_name = %s, category_type = %s, planned_expenses = %s, category_color = %s, category_icon = %s
            WHERE category_id = %s AND user_id = %s AND is_deleted = FALSE
        ''', (category_name, category_type, planned_expenses, category_color, category_icon, category_id, user_id))
        self.connection.commit()

    def delete_category(self, category_id, user_id):
        cursor = self.connection.cursor()
        cursor.execute('''
            UPDATE categories 
            SET is_deleted = TRUE
            WHERE category_id = %s AND user_id = %s
        ''', (category_id, user_id))
        self.connection.commit()

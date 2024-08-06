from app.config.db_config import create_connection

class CardModel:
    def __init__(self):
        self.connection = create_connection()

    def create_table(self):
        cursor = self.connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS cards (
                card_id INT PRIMARY KEY AUTO_INCREMENT,
                user_id INT,
                card_name VARCHAR(100) NOT NULL,
                card_type VARCHAR(100) NOT NULL,
                balance FLOAT NOT NULL,
                is_deleted BOOLEAN DEFAULT FALSE, 
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        ''')
        self.connection.commit()

    def add_card(self, user_id, card_name, card_type, balance):
        cursor = self.connection.cursor()
        cursor.execute('''
            INSERT INTO cards (user_id, card_name, card_type, balance)
            VALUES (%s, %s, %s, %s)
        ''', (user_id, card_name, card_type, balance))
        self.connection.commit()

    def get_user_cards(self, user_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('SELECT * FROM cards WHERE user_id = %s', (user_id,))
        return cursor.fetchall()

    def get_card_by_id(self, card_id):
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute('SELECT * FROM cards WHERE card_id = %s AND is_deleted = FALSE', (card_id,))
        return cursor.fetone()

    def update_card(self, card_id, user_id, card_name, card_type, balance):
        cursor = self.connection.cursor()
        cursor.execute('''
            UPDATE cards 
            SET card_name = %s, card_type = %s, balance = %s 
            WHERE card_id = %s AND user_id = %s AND is_deleted = FALSE
        ''', (card_name, card_type, balance, card_id, user_id))
        self.connection.commit()

    def delete_card(self, card_id, user_id):
        cursor = self.connection.cursor()
        cursor.execute('''
            UPDATE cards
            SET is_deleted = TRUE 
            WHERE card_id = %s AND user_id = %s
        ''', (card_id, user_id))
        self.connection.commit()

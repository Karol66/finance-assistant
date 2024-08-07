from app.models.card_model import CardModel

class CardService:
    def __init__(self):
        self.card_model = CardModel()
        self.card_model.create_table()

    def create_card(self, user_id, card_name, card_number, cvv, card_type, balance):
        self.card_model.add_card(user_id, card_name, card_number, cvv, card_type, balance)

    def get_user_cards(self, user_id):
        return self.card_model.get_user_cards(user_id)

    def get_card_by_id(self, card_id):
        return self.card_model.get_card_by_id(card_id)

    def update_card(self, card_id, user_id, card_name, card_number, cvv, card_type, balance):
        self.card_model.update_card(card_id, user_id, card_name, card_number, cvv, card_type, balance)

    def delete_card(self, card_id, user_id):
        self.card_model.delete_card(card_id, user_id)

from app.models.card_model import CardModel

class CardService:
    def __init__(self):
        self.card_model = CardModel()
        self.card_model.create_table()

    def create_card(self, user_id, card_name, card_type, balance):
        self.card_model.add_card(user_id, card_name, card_type, balance)

    def get_user_cards(self, user_id):
        return self.card_model.get_user_cards(user_id)

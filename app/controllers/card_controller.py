from app.services.card_service import CardService

class CardController:
    def __init__(self):
        self.card_service = CardService()

    def create_card(self, user_id, card_name, card_type, balance):
        self.card_service.create_card(user_id, card_name, card_type, balance)

    def get_user_cards(self, user_id):
        return self.card_service.get_user_cards(user_id)

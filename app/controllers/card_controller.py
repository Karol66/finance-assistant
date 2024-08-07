from app.services.card_service import CardService

class CardController:
    def __init__(self):
        self.card_service = CardService()

    def create_card(self, user_id, card_name, card_number, cvv, card_type, balance):
        self.card_service.create_card(user_id, card_name, card_number, cvv, card_type, balance)

    def get_user_cards(self, user_id):
        return self.card_service.get_user_cards(user_id)

    def get_card_by_id(self, card_id):
        return self.card_service.get_card_by_id(card_id)

    def update_card(self, card_id, user_id, card_name, card_number, cvv, card_type, balance):
        self.card_service.update_card(card_id, user_id, card_name, card_number, cvv, card_type, balance)

    def delete_card(self, card_id, user_id):
        self.card_service.delete_card(card_id, user_id)

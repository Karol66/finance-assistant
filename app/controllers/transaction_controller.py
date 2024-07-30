from app.services.transaction_service import TransactionService

class TransactionController:
    def __init__(self):
        self.transaction_service = TransactionService()

    def add_transaction(self, amount, account_id, transaction_date, description, category_id, user_id):
        return self.transaction_service.add_transaction(amount, account_id, transaction_date, description, category_id, user_id)

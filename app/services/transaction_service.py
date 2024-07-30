from app.models.transaction_model import TransactionModel

class TransactionService:
    def __init__(self):
        self.transaction_model = TransactionModel()

    def add_transaction(self, amount, account_id, transaction_date, description, category_id, user_id):
        return self.transaction_model.add_transaction(amount, account_id, transaction_date, description, category_id, user_id)

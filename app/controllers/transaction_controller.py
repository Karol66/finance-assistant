from app.services.transaction_service import TransactionService

class TransactionController:
    def __init__(self):
        self.transaction_service = TransactionService()

    def add_transaction(self, amount, account_id, transaction_date, description, category_id, user_id):
        return self.transaction_service.add_transaction(amount, account_id, transaction_date, description, category_id, user_id)

    def get_transactions_by_user_id(self, user_id):
        return self.transaction_service.get_transactions_by_user_id(user_id)

    def get_chart_data(self, user_id, category_type):
        return self.transaction_service.get_chart_data(user_id, category_type)
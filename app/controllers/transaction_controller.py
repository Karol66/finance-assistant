from app.services.transaction_service import TransactionService

class TransactionController:
    def __init__(self):
        self.transaction_service = TransactionService()

    def add_transaction(self, user_id, amount, account_id, transaction_date, description, category_id, ):
        return self.transaction_service.add_transaction(user_id, amount, account_id, transaction_date, description, category_id)

    def get_transactions(self, user_id):
        return self.transaction_service.get_transactions(user_id)

    def get_chart_data(self, user_id, category_type):
        return self.transaction_service.get_chart_data(user_id, category_type)

    def get_transaction_by_id(self, transaction_id):
        return self.transaction_service.get_transaction_by_id(transaction_id)

    def update_transaction(self, transaction_id, user_id, amount, account_id, transaction_date, description, category_id):
        self.transaction_service.update_transaction(transaction_id, user_id, amount, account_id, transaction_date, description, category_id)

    def delete_transaction(self, transaction_id, user_id):
        self.transaction_service.delete_transaction(transaction_id, user_id)

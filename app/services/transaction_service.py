from app.controllers.category_controller import CategoryController
from app.models.transaction_model import TransactionModel


class TransactionService:
    def __init__(self):
        self.transaction_model = TransactionModel()

    def add_transaction(self, amount, account_id, transaction_date, description, category_id, user_id):
        return self.transaction_model.add_transaction(amount, account_id, transaction_date, description, category_id, user_id)

    def get_transactions(self, user_id):
        return self.transaction_model.get_user_transactions(user_id)

    def get_transaction_by_id(self, transaction_id):
        return self.transaction_model.get_transaction_by_id(transaction_id)

    def update_transaction(self, transaction_id, user_id, amount, account_id, transaction_date, description, category_id):
        self.transaction_model.update_transaction(transaction_id, user_id, amount, account_id, transaction_date, description, category_id)

    def delete_transaction(self, transaction_id, user_id):
        self.transaction_model.delete_transaction(transaction_id, user_id)

    def get_chart_data(self, user_id, category_type):
        transactions = self.get_transactions(user_id)
        categories = CategoryController().get_user_categories(user_id)

        category_dict = {cat["category_id"]: cat for cat in categories}
        chart_data = []

        for transaction in transactions:
            category = category_dict.get(transaction["category_id"])
            if category and category["category_type"] == category_type:
                chart_data.append({
                    "value": float(transaction["amount"]),
                    "color": category["category_color"],
                })
        return chart_data
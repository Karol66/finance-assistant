from app.models.account_model import AccountModel

class AccountService:
    def __init__(self):
        self.account_model = AccountModel()
        self.account_model.create_table()

    def create_account(self, user_id, account_name, account_type, balance):
        self.account_model.add_account(user_id, account_name, account_type, balance)

    def get_user_accounts(self, user_id):
        return self.account_model.get_accounts_by_user_id(user_id)
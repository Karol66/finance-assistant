from app.services.account_service import AccountService

class AccountController:
    def __init__(self):
        self.account_service = AccountService()

    def create_account(self, user_id, account_name, account_type, balance):
        self.account_service.create_account(user_id, account_name, account_type, balance)

    def get_user_accounts(self, user_id):
        return self.account_service.get_user_accounts(user_id)

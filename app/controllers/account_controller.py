from app.services.account_service import AccountService

class AccountController:
    def __init__(self):
        self.account_service = AccountService()

    def create_account(self, user_id, account_name, account_type, balance, account_color, account_icon, card_id, include_in_total):
        self.account_service.create_account(user_id, account_name, account_type, balance, account_color, account_icon, card_id, include_in_total)

    def get_user_accounts(self, user_id):
        return self.account_service.get_user_accounts(user_id)

    def get_account_by_id(self, account_id):
        self.account_service.get_account_by_id(account_id)

    def update_account(self, account_id, user_id, account_name, account_type, balance, account_color, account_icon, card_id, include_in_total):
        self.account_service.update_account(account_id, user_id, account_name, account_type, balance, account_color, account_icon, card_id, include_in_total)

    def delete_account(self, account_id, user_id):
        self.account_service.delete_account(account_id, user_id)

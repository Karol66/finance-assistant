from app.services.user_service import UserService

class UserController:
    def __init__(self):
        self.user_service = UserService()

    def register_user(self, email, username, password, confirm_password):
        return self.user_service.register_user(email, username, password, confirm_password)

    def login_user(self, identifier, password):
        return self.user_service.login_user(identifier, password)

    def update_category(self, user_id, email, username, password):
        self.user_service.update_user(user_id, email, username, password)
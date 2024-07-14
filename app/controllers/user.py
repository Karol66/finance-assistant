from app.services.user import UserService

class UserController:
    def __init__(self):
        self.user_service = UserService()

    def register_user(self, email, username, password, confirm_password):
        return self.user_service.register_user(email, username, password, confirm_password)

    def login_user(self, identifier, password):
        return self.user_service.login_user(identifier, password)


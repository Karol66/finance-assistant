from app.models.user_model import UserModel


class UserService:
    def __init__(self):
        self.user_model = UserModel()
        self.user_model.create_table()

    def register_user(self, email, username, password, confirm_password):
        if password != confirm_password:
            return {"status": "error", "message": "Passwords do not match"}

        existing_user = self.user_model.get_user_by_email(email)
        if existing_user:
            return {"status": "error", "message": "Email is already registered"}

        existing_user_by_username = self.user_model.get_user_by_username(username)
        if existing_user_by_username:
            return {"status": "error", "message": "Username is already taken"}

        self.user_model.add_user(email, username, password)
        return {"status": "success", "message": "User registered successfully"}

    def login_user(self, identifier, password):
        user = self.user_model.validate_user(identifier, password)
        if user:
            return {"status": "success", "message": "Login successful", "user": user}
        else:
            return {"status": "error", "message": "Invalid email/username or password"}

    def update_user(self, user_id, email, username, password):
        self.user_model.update_user(user_id, email, username, password)
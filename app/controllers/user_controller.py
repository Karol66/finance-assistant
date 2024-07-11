from app.models.user import UserModel

class UserController:
    def __init__(self):
        self.user_model = UserModel()
        self.user_model.create_table()

    def register_user(self, email, password, confirm_password):
        if password != confirm_password:
            return {"status": "error", "message": "Passwords do not match"}

        existing_user = self.user_model.get_user_by_email(email)
        if existing_user:
            return {"status": "error", "message": "Email is already registered"}

        self.user_model.add_user(email, password)
        return {"status": "success", "message": "User registered successfully"}

    def login_user(self, email, password):
        if self.user_model.validate_user(email, password):
            return {"status": "success", "message": "Login successful"}
        else:
            return {"status": "error", "message": "Invalid email or password"}

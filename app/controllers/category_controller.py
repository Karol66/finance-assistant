from app.services.category_service import CategoryService


class CategoryController:
    def __init__(self):
        self.category_service = CategoryService()

    def create_account(self, user_id, category_name, category_type, planned_expanses, category_color, category_icon):
        self.category_service.create_category(user_id, category_name, category_type, planned_expanses, category_color, category_icon)

    def get_user_categories(self, user_id):
        return self.category_service.get_user_categories(user_id)

    def get_chart_data(self, user_id, category_type):
        return self.category_service.get_chart_data(user_id, category_type)

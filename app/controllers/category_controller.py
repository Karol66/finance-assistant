from app.services.category_service import CategoryService


class CategoryController:
    def __init__(self):
        self.category_service = CategoryService()

    def create_category(self, user_id, category_name, category_type, planned_expanses, category_color, category_icon):
        self.category_service.create_category(user_id, category_name, category_type, planned_expanses, category_color, category_icon)

    def get_user_categories(self, user_id):
        return self.category_service.get_user_categories(user_id)

    def get_category_by_id(self, category_id):
        return self.category_service.get_category_by_id(category_id)

    def update_category(self, category_id, user_id, category_name, category_type, planned_expanses, category_color, category_icon):
        self.category_service.update_category(category_id, user_id, category_name, category_type, planned_expanses, category_color, category_icon)

    def delete_category(self, category_id, user_id):
        self.category_service.delete_category(category_id, user_id)

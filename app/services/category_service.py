from app.models.category_model import CategoryModel


class CategoryService:
    def __init__(self):
        self.category_model = CategoryModel()
        self.category_model.create_table()

    def create_category(self, user_id, category_name, category_type, planned_expanses, category_color, category_icon):
        self.category_model.add_category(user_id, category_name, category_type, planned_expanses, category_color, category_icon)

    def get_user_categories(self, user_id):
        return self.category_model.get_user_categories(user_id)

    def get_category_by_id(self, category_id):
        return self.category_model.get_category_by_id(category_id)

    def update_category(self, category_id, user_id, category_name, category_type, planned_expanses, category_color, category_icon):
        self.category_model.update_category(category_id, user_id, category_name, category_type, planned_expanses, category_color, category_icon)

    def delete_category(self, category_id, user_id):
        self.category_model.delete_category(category_id, user_id)

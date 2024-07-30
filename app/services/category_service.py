from app.models.category_model import CategoryModel


class CategoryService:
    def __init__(self):
        self.account_model = CategoryModel()
        self.account_model.create_table()

    def create_category(self, user_id, category_name, category_type, planned_expanses, category_color, category_icon):
        self.account_model.add_category(user_id, category_name, category_type, planned_expanses, category_color,
                                        category_icon)

    def get_user_categories(self, user_id):
        return self.account_model.get_categories_by_user_id(user_id)

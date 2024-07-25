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

    def get_chart_data(self, user_id, category_type):
        categories = self.get_user_categories(user_id)
        chart_data = []
        for category in categories:
            if category["category_type"] == category_type:
                planned_expanses = category["planned_expenses"]

                if planned_expanses:
                    value = float(planned_expanses)
                else:
                    value = 0.0

                chart_data.append({
                    "value": value,
                    "color": category["category_color"],
                })
        return chart_data
import flet
from flet import *

from app.models.account_model import AccountModel
from app.models.category import CategoryModel
from app.models.notification import NotificationModel
from app.models.payment import PaymentModel
from app.models.statistic import StatisticModel
from app.models.transaction import TransactionModel
from app.models.user_model import UserModel
from app.views.dashboard import dashboard_page
from app.views.login_view import login_page
import app.globals as g

def initialize_database():
    user_model = UserModel()
    user_model.create_table()

    account_model = AccountModel()
    account_model.create_table()

    category_model = CategoryModel()
    category_model.create_table()

    notification_model = NotificationModel()
    notification_model.create_table()

    payment_model = PaymentModel()
    payment_model.create_table()

    statistic_model = StatisticModel()
    statistic_model.create_table()

    transaction_model = TransactionModel()
    transaction_model.create_table()


def main(page: Page):
    initialize_database()
    if g.logged_in_user is None:
        # login_page(page)
        dashboard_page(page)
    else:
        dashboard_page(page)
    page.update()


if __name__ == '__main__':
    app(target=main)

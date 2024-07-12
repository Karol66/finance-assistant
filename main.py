import flet
from flet import *
from app.views.dashboard import dashboard_page


def main(page: Page):
    dashboard_page(page)
    page.update()


if __name__ == '__main__':
    app(target=main)

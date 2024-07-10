import flet
from flet import *
from app import App


def wallet_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"

    page.title = "Wallite"

    page.window_size = 450,
    page.window_height = 790,

    page.update()

    app = App()
    page.add(app)


if __name__ == '__main__':
    flet.app(target=wallet_page)

import flet
from flet import *
from app.navigation import create_navigation_drawer


def wallet_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"

    drawer = create_navigation_drawer(page)
    page.add(
        AppBar(
            Row(
                controls=[
                    IconButton(
                        icon=icons.MENU_ROUNDED,
                        icon_size=25,
                        icon_color="white",
                        on_click=lambda e: page.open(drawer),
                    ),
                ],
            ),
            title=Text('Wallet', color="white"),
            bgcolor="black",
        ),
    )
    page.update()

if __name__ == '__main__':
    flet.app(target=wallet_page)

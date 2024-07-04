import flet
from flet import *
from navigation import create_navigation_drawer

def wallet_page(page: Page):
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
        Text("This is the Wallet Page")
    )
    page.update()


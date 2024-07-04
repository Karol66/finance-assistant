import flet
from flet import *
from navigation import create_navigation_drawer

def main(page: Page):
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
            title=Text('Dashboard', color="white"),
            bgcolor="black",
        ),
        Text("This is the Dashboard Page")
    )
    page.update()

if __name__ == '__main__':
    flet.app(target=main)

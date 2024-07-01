import flet
from flet import *


class MainStackContainer(UserControl):
    def __init__(self):
        super().__init__()

    def HideMenu(self, e):
        main = self.controls[0].content.controls[0].controls[0]
        menu = self.controls[0].content.controls[1].controls[0]

        menu.width = 0
        menu.update()
        main.opacity = 1
        main.update()

    def ShowMenu(self, e):
        # kontrolka strony głównej
        main = self.controls[0].content.controls[0].controls[0]
        # kontrolka menu
        menu = self.controls[0].content.controls[1].controls[0]

        if menu.width == 0:
            menu.width = 185
            menu.update()

            main.opacity = 0.35
            main.update()

        else:
            menu.width = 0
            menu.border = None
            menu.update()

            main.opacity = 1
            main.update()

        pass

    def build(self):
        return Container(
            width=280,
            height=600,
            bgcolor="white",
            border_radius=32,
            border=border.all(8, "black"),
            padding=padding.only(top=25, left=5, right=5, bottom=25),
            content=Stack(
                expand=True,
                controls=[
                    MainPage(self.ShowMenu, self.HideMenu),
                    MenuPage(self.ShowMenu, self.HideMenu),
                ]
            )
        )


class MainPage(UserControl):
    def __init__(self, function, function2):
        self.function = function
        self.function2 = function2
        super().__init__()

    def build(self):
        return Container(
            expand=True,
            clip_behavior=ClipBehavior.HARD_EDGE,
            opacity=1,
            animate_opacity=300,
            on_click=self.function2,
            content=Column(
                controls=[
                    Row(
                        controls=[
                            Row(
                                expand=1,
                                alignment=MainAxisAlignment.START,
                                controls=[
                                    IconButton(
                                        icon=icons.MENU_ROUNDED,
                                        icon_size=15,
                                        icon_color="black",
                                        on_click=self.function,
                                    )
                                ],
                            ),
                            Row(
                                expand=3,
                                alignment=MainAxisAlignment.START,
                                controls=[
                                    Text(
                                        "Filter Your Data",
                                        size=15,
                                        color="black",
                                        weight="bold",
                                    )
                                ],
                            ),
                        ]
                    ),
                    Container(
                        padding=padding.only(left=15, right=5),
                        opacity=0.85,
                        content=Divider(height=5, color="black")
                    ),
                ]
            )
        )


class MenuPage(UserControl):
    def __init__(self, function, function2):
        self.function = function
        self.function2 = function2
        super().__init__()

    def HighLight(self, e):
        if e.data == "true":
            e.control.bgcolor = "white10"
            e.control.update()

            e.control.content.controls[0].icon_color = "white"
            e.control.content.controls[1].color = "white"
            e.control.content.update()
        else:
            e.control.bgcolor = None
            e.control.update()

            e.control.content.controls[0].icon_color = "white54"
            e.control.content.controls[1].color = "white54"
            e.control.content.update()

    def UserData(self, initials: str, name: str, description: str):
        return Container(
            content=Row(
                controls=[
                    Container(
                        width=42,
                        height=42,
                        bgcolor="bluegrey900",
                        alignment=alignment.center,
                        border_radius=8,
                        content=Text(
                            value=initials,
                            size=20,
                            weight="bold",
                            color="white"
                        ),
                    ),
                    Column(
                        spacing=1,
                        alignment=alignment.center,
                        controls=[
                            Text(
                                value=name,
                                size=11,
                                weight="bold",

                                opacity=1,
                                animate_opacity=200,
                                color="white"
                            ),
                            Text(
                                value=description,
                                size=9,
                                weight="w400",

                                opacity=1,
                                animate_opacity=200,
                                color="white54"
                            ),
                        ]
                    )
                ]
            )
        )

    def CintainedIcon(self, icon_name: str, text: str):
        return Container(
            width=180,
            height=45,
            border_radius=10,
            on_hover=lambda e: self.HighLight(e),
            content=Row(
                controls=[
                    IconButton(
                        icon=icon_name,
                        icon_size=18,
                        icon_color="white54",
                        style=ButtonStyle(
                            shape={
                                "": RoundedRectangleBorder(radius=7),
                            },
                            overlay_color={
                                "": "transparent"
                            }
                        ),
                    ),
                    Text(
                        value=text,
                        color="white54",
                        size=11,
                        opacity=1,
                        animate_opacity=200,
                    )
                ]
            ),
        )

    def build(self):
        return Container(
            width=0,
            bgcolor="black",
            animate=animation.Animation(400, "decelerate"),
            clip_behavior=ClipBehavior.HARD_EDGE,
            content=Column(
                expand=True,
                controls=[
                    self.UserData("JK", "Jan Kowalski", "Software Engineer"),
                    Divider(height=5, color="transparent"),
                    self.CintainedIcon(icons.SEARCH, "Search"),
                    self.CintainedIcon(icons.DASHBOARD_ROUNDED, "Dashboard"),
                    self.CintainedIcon(icons.BAR_CHART, "Revenue"),
                    self.CintainedIcon(icons.NOTIFICATIONS, "Notifications"),
                    self.CintainedIcon(icons.PIE_CHART_ROUNDED, "Analytics"),
                    self.CintainedIcon(icons.FAVORITE_ROUNDED, "Likes"),
                    self.CintainedIcon(icons.WALLET_ROUNDED, "Wallet"),
                    Divider(height=5, color="white24"),
                    self.CintainedIcon(icons.LOGOUT_ROUNDED, "Logout"),
                ]
            )
        )


def main(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"
    page.bgcolor = "deeppurple200"

    page.add(
        MainStackContainer(),
    )

    page.update()

    pass


if __name__ == "__main__":
    flet.app(target=main)

import flet
from flet import *
from functools import partial
import time


class ModernNavBar(UserControl):
    def __init__(self):
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
            width=200,
            height=580,
            padding=padding.only(top=10),
            alignment=alignment.center,
            content=Column(
                alignment=MainAxisAlignment.CENTER,
                horizontal_alignment=CrossAxisAlignment.CENTER,
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
            ),
        )


def main(page: Page):
    page.title = "Sidebar"

    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"

    page.add(
        Container(
            width=200,
            height=580,
            bgcolor="black",
            border_radius=10,
            animate=animation.Animation(500, "decelerate"),
            alignment=alignment.center,
            padding=10,
            content=ModernNavBar(),
        )
    )

    page.update()


if __name__ == "__main__":
    flet.app(target=main)

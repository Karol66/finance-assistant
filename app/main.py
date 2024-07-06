import flet
from flet import *
from navigation import create_navigation_drawer


class Expanse(UserControl):

    def hover_animation(self, e):
        if e.data == "true":
            e.control.content.controls[2].offset = transform.Offset(0, 0)
            e.control.content.controls[2].opacity = 1.0
            e.control.update()
        else:
            e.control.content.controls[2].offset = transform.Offset(0, 1)
            e.control.content.controls[2].opacity = 0.0
            e.control.update()

        pass

    def icon(self, name, color):
        return Icon(
            name=name,
            size=18,
            color=color,
        )

    def MianContainer(self):
        self.main = Container(
            width=290,
            height=600,
            bgcolor="black",
            border_radius=35,
            padding=8,
        )

        self.main_col = Column(

        )

        self.green_container = Container(
            width=self.main.width,
            height=self.main.height * 0.45,
            border_radius=30,
            gradient=LinearGradient(
                begin=alignment.top_left,
                end=alignment.bottom_right,
                colors=["#0f766e", "#064e3b"],
            )
        )

        self.notification = self.icon(icons.NOTIFICATIONS, "white54")
        self.hide = self.icon(icons.HIDE_SOURCE, "white54")
        self.chat = self.icon(icons.CHAT, "white54")

        self.icon_column = Column(
            alignment="center",
            spacing=5,
            controls=[
                self.notification,
                self.hide,
                self.chat,
            ],
        )

        self.inner_green_container = Container(
            width=self.green_container.width,
            height=self.green_container.height,
            content=Row(
                spacing=0,
                controls=[
                    Column(
                        expand=4,
                        controls=[
                            Container(
                                padding=20,
                                expand=True,
                                content=Row(
                                    controls=[
                                        Column(
                                            controls=[
                                                Text(
                                                    "Welcome back",
                                                    size=10,
                                                    color="white70",
                                                ),
                                                Text(
                                                    "Jan Kowalski",
                                                    size=18,
                                                    weight="bold",
                                                    color="white",
                                                ),
                                                Container(
                                                    padding=padding.only(
                                                        top=35, bottom=35
                                                    ),
                                                ),
                                                Text(
                                                    "Total Current Balance",
                                                    size=10,
                                                    color="white70",
                                                ),
                                                Text(
                                                    "123,123.123",
                                                    size=22,
                                                    weight="bold",
                                                    color="white",
                                                ),
                                            ]
                                        )
                                    ]
                                )
                            )
                        ]
                    ),
                    Column(
                        expand=1,
                        controls=[
                            Container(
                                padding=padding.only(right=10),
                                expand=True,
                                content=Row(
                                    alignment=MainAxisAlignment.CENTER,
                                    controls=[
                                        Column(
                                            alignment=MainAxisAlignment.CENTER,
                                            horizontal_alignment=CrossAxisAlignment.CENTER,
                                            controls=[
                                                Column(
                                                    alignment=MainAxisAlignment.CENTER,
                                                    horizontal_alignment=CrossAxisAlignment.CENTER,
                                                    controls=[
                                                        Container(
                                                            width=40,
                                                            height=150,
                                                            bgcolor="white10",
                                                            border_radius=14,
                                                            content=self.icon_column
                                                        )
                                                    ]
                                                )
                                            ]
                                        )
                                    ]
                                )
                            ),

                        ]
                    )
                ]
            )
        )

        self.grid_transfers = GridView(
            expand=True,
            max_extent=150,
            runs_count=0,
            spacing=12,
            run_spacing=5,
            horizontal=True,
        )

        self.grid_payments = GridView(
            expand=True,
            max_extent=150,
            runs_count=0,
            spacing=12,
            run_spacing=5,
        )

        self.main_content_area = Container(
            width=self.main.width,
            height=self.main.height * 0.50,
            bgcolor="black",
            padding=padding.only(top=10, left=10, right=10),
            content=Column(
                spacing=20,
                controls=[
                    Row(
                        alignment="spaceBetween",
                        vertical_alignment="end",
                        controls=[
                            Container(
                                content=Text(
                                    "Recent Transfers",
                                    size=14,
                                    weight="bold",
                                    color="white",
                                )
                            ),
                            Container(
                                content=Text(
                                    "View all",
                                    size=10,
                                    weight="w400",
                                    color="white54",
                                )
                            ),
                        ]
                    ),
                    Container(
                        height=50,
                        content=self.grid_transfers,
                    ),
                    Row(
                        alignment="spaceBetween",
                        vertical_alignment="end",
                        controls=[
                            Container(
                                content=Text(
                                    "Pending Payments",
                                    size=14,
                                    weight="bold",
                                    color="white",
                                )
                            ),
                            Container(
                                content=Text(
                                    "View all",
                                    size=10,
                                    weight="w400",
                                    color="white54",
                                )
                            ),
                        ]
                    ),
                    self.grid_payments,
                ]
            )
        )

        info_list = ["PH", "SG", "LO", "HS", "AW", "KL", "OI", "AP"]
        for i in info_list:
            __ = Container(
                width=100,
                height=100,
                bgcolor="white10",
                border_radius=15,
                alignment=alignment.center,
                content=Text(f"{i}", weight="bold", color="white"),
            )
            self.grid_transfers.controls.append(__)

        payment_list = [
            ["Utilites", "$100.25"],
            ["Phone", "$100.25"],
            ["Electricity", "$100.25"],
            ["Car", "$100.25"],
            ["Travels", "$100.25"],
            ["Network", "$100.25"],
        ]
        for i in payment_list:
            __ = Container(
                width=100,
                height=100,
                bgcolor="white10",
                border_radius=15,
                alignment=alignment.center,
                content=Text(f"{i}", weight="bold", color="white"),
                on_hover=lambda e:self.hover_animation(e),
            )
            self.grid_payments.controls.append(__)

            for x in i:
                __.content = Column(
                    alignment="center",
                    horizontal_alignment="center",
                    controls=[
                        Text(
                            f"{i[0]}",
                            size=11,
                            color="white54",
                        ),
                        Text(
                            f"{i[1]}",
                            size=16,
                            weight="bold",
                            color="white",
                        ),
                        Text(
                            "Pay Now?",
                            color="white60",
                            size=12,
                            text_align="start",
                            weight="w600",
                            offset=transform.Offset(0, 1),
                            animate_offset=animation.Animation(
                                duration=900,
                                curve="decelerate",
                            ),
                            animate_opacity=300,
                            opacity=0,
                        )
                    ],
                )

        self.green_container.content = self.inner_green_container

        self.main_col.controls.append(self.green_container)
        self.main_col.controls.append(self.main_content_area)

        self.main.content = self.main_col

        return self.main

    def build(self):
        return Column(
            controls=[
                self.MianContainer(),
            ]
        )


def main(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"

    app = Expanse()
    page.add(app)

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

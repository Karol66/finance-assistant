import flet
from flet import *
from navigation import create_navigation_drawer

class Expanse(UserControl):
    def build(self):
        self.main_col = Column(
            expand=True,
            alignment="center",
            horizontal_alignment="center",
        )

        self.grid_transfers = GridView(
            expand=True,
            max_extent=100,
            spacing=10,
            run_spacing=10,
        )

        self.main_content_area = Container(
            width=400,
            height=700,
            bgcolor="black",
            padding=padding.only(top=10, left=10, right=10),
            content=Column(
                spacing=20,
                controls=[
                    Row(
                        alignment="spaceBetween",
                        vertical_alignment="end",
                        controls=[
                        ]
                    ),
                    self.grid_transfers,
                ]
            )
        )

        payment_list = [
            [icons.DIRECTIONS_CAR, "Car"],
            [icons.PHONE, "Phone"],
            [icons.BOLT, "Electricity"],
            [icons.FLIGHT, "Travels"],
            [icons.NETWORK_WIFI, "Network"],
            [icons.HOME, "Utilities"],
        ]

        for i in payment_list:
            item_container = Container(
                width=100,
                height=100,
                bgcolor="white10",
                border_radius=15,
                alignment=alignment.center,
                content=Column(
                    alignment="center",
                    horizontal_alignment="center",
                    controls=[
                        Icon(
                            f"{i[0]}",
                            size=30,
                            color="white",
                        ),
                        Text(f"{i[1]}", size=12, color="white", weight="bold"),
                    ]
                )
            )
            self.grid_transfers.controls.append(item_container)

        add_button = Container(
            width=100,
            height=100,
            bgcolor="green",
            border_radius=15,
            alignment=alignment.center,
            content=Column(
                alignment="center",
                horizontal_alignment="center",
                controls=[
                    Icon(
                        icons.ADD,
                        size=30,
                        color="white",
                    ),
                    # Text("Create", size=12, color="white", weight="bold"),
                ]
            )
        )
        self.grid_transfers.controls.append(add_button)

        self.main_col.controls.append(
            Row(
                controls=[
                    Container(
                        content=Text(
                            "Revenue",
                            size=18,
                            color=flet.colors.WHITE,
                            weight="bold",
                        ),
                        on_click=lambda e: print("Revenue clicked"),
                        padding=padding.symmetric(horizontal=10, vertical=5),
                        border_radius=5,
                    ),
                    Container(width=20),
                    Container(
                        content=Text(
                            "Income",
                            size=18,
                            color=flet.colors.WHITE,
                            weight="bold",
                        ),
                        on_click=lambda e: print("Income clicked"),
                        padding=padding.symmetric(horizontal=10, vertical=5),
                        border_radius=5,
                    ),
                ],
                alignment="center",
                vertical_alignment="center"
            )
        )

        self.main_col.controls.append(self.main_content_area)

        return self.main_col

def categories_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"
    page.bgcolor = "black"

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
            title=Text('Categories', color="white"),
            bgcolor="black",
        ),
    )
    page.update()

if __name__ == '__main__':
    flet.app(target=categories_page)

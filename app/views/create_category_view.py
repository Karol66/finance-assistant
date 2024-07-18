import flet
from flet import *
from app.views.navigation_view import create_navigation_drawer


class Expanse(UserControl):

    def __init__(self):
        super().__init__()
        self.selected_link = None

    def InputTextField(self, text: str, hide: bool, ref):
        return Container(
            alignment=alignment.center,
            content=TextField(
                height=58,
                width=300,
                bgcolor="#f0f3f6",
                text_size=14,
                color="black",
                border_color="transparent",
                hint_text=text,
                filled=True,
                cursor_color="black",
                hint_style=TextStyle(
                    size=13,
                    color="black",
                ),
                password=hide,
                ref=ref,
            ),
        )

    def on_link_click(self, e, link_name):
        self.selected_link = link_name
        self.update_links()

    def update_links(self):
        for link in self.links:
            link.border = border.only(bottom=border.BorderSide(2, "transparent"))
            if link.data == self.selected_link:
                link.border = border.only(bottom=border.BorderSide(2, "white"))
            link.update()

    def build(self):
        self.category_name_input = Ref[TextField]()
        self.planned_expenses_input = Ref[TextField]()

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
            padding=padding.only(top=10, left=10, right=10, bottom=10),
            content=Column(
                spacing=20,
                controls=[
                    Row(
                        alignment="spaceBetween",
                        vertical_alignment="end",
                        controls=[
                            Column(
                                controls=[
                                    self.InputTextField("Category name", False, self.category_name_input),
                                    # Dodane RadioGroup z białymi etykietami
                                    RadioGroup(
                                        content=Row(
                                            controls=[
                                                Radio(value="Expenses", label="Expenses", label_style=TextStyle(color=colors.WHITE)),
                                                Radio(value="Income", label="Income", label_style=TextStyle(color=colors.WHITE)),
                                            ],
                                            alignment="center"
                                        ),
                                    ),
                                    self.InputTextField("Planned expenses", False, self.planned_expenses_input),
                                ]
                            )
                        ]
                    ),
                    # Dodany pasek z kolorowymi kółkami i szarym kółkiem z ikoną plusa
                    Row(
                        alignment="center",
                        controls=[
                            Container(width=30, height=30, bgcolor=colors.RED, border_radius=15, margin=1),
                            Container(width=30, height=30, bgcolor=colors.GREEN, border_radius=15, margin=1),
                            Container(width=30, height=30, bgcolor=colors.BLUE, border_radius=15, margin=1),
                            Container(width=30, height=30, bgcolor=colors.YELLOW, border_radius=15, margin=1),
                            Container(width=30, height=30, bgcolor=colors.ORANGE, border_radius=15, margin=1),
                            Container(width=30, height=30, bgcolor=colors.PURPLE, border_radius=15, margin=1),
                            Container(width=30, height=30, bgcolor=colors.BROWN, border_radius=15, margin=1),
                            Container(width=30, height=30, bgcolor=colors.PINK, border_radius=15, margin=1),
                            Container(
                                width=30,
                                height=30,
                                bgcolor=colors.GREY,
                                border_radius=15,
                                margin=1,
                                alignment=alignment.center,
                                content=Icon(
                                    icons.ADD,
                                    size=16,
                                    color="white",
                                ),
                            ),
                        ]
                    ),
                    self.grid_transfers,
                ]
            )
        )

        icon_list = [
            [icons.DIRECTIONS_CAR],
            [icons.PHONE],
            [icons.BOLT],
            [icons.FLIGHT],
            [icons.NETWORK_WIFI],
            [icons.HOME],
            [icons.FOOD_BANK],
            [icons.SCHOOL],
            [icons.HEALTH_AND_SAFETY],
            [icons.THEATER_COMEDY],
            [icons.SHOPPING_BAG],
            [icons.SPORTS],
            [icons.WORK],
            [icons.FOREST],
            [icons.TRAVEL_EXPLORE],
        ]

        for i in icon_list:
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
                            size=40,
                            color="white",
                        ),
                    ]
                )
            )
            self.grid_transfers.controls.append(item_container)

        more_button = Container(
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
                        icons.MORE_HORIZ,
                        size=30,
                        color="white",
                    ),
                ]
            )
        )
        self.grid_transfers.controls.append(more_button)

        self.links = [
            Container(
                width=175,
                content=Text(
                    "Revenue",
                    size=18,
                    color=colors.WHITE,
                    weight="bold",
                ),
                on_click=lambda e: self.on_link_click(e, "Expenses"),
                padding=padding.symmetric(horizontal=10, vertical=5),
                data="Revenue",
                border=border.only(bottom=border.BorderSide(2, "transparent")),
                alignment=alignment.center,
            ),
            Container(
                width=175,
                content=Text(
                    "Income",
                    size=18,
                    color=colors.WHITE,
                    weight="bold",
                ),
                on_click=lambda e: self.on_link_click(e, "Income"),
                padding=padding.symmetric(horizontal=10, vertical=5),
                data="Income",
                border=border.only(bottom=border.BorderSide(2, "transparent")),
                alignment=alignment.center,
            ),
        ]

        self.main_col.controls.append(
            Row(
                controls=self.links,
                alignment="center",
                vertical_alignment="center",
                spacing=0,
            )
        )

        self.main_col.controls.append(self.main_content_area)

        return self.main_col


def categories_page(page: Page):
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
            title=Text('Categories', color="white"),
            bgcolor="#132D46",
        ),
    )
    page.update()


if __name__ == '__main__':
    flet.app(target=categories_page)

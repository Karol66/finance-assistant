import flet
from flet import *
from app.views.navigation_view import create_navigation_drawer


class Expanse(UserControl):

    def __init__(self):
        super().__init__()
        self.selected_link = None
        self.selected_color_container = None
        self.selected_color = None
        self.last_selected_icon = None
        self.last_selected_icon_original_color = None

    def InputTextField(self, text: str, hide: bool, ref):
        return Container(
            alignment=alignment.center,
            content=TextField(
                height=58,
                width=380,
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

    def on_color_click(self, e):
        if self.selected_color_container == e.control:
            # Odznaczenie obecnie zaznaczonego kontenera
            self.selected_color_container.content.controls = []
            self.selected_color_container.update()
            self.selected_color_container = None
            self.selected_color = None
        else:
            if self.selected_color_container:
                # Usunięcie ikony zatwierdzenia z poprzednio wybranego kontenera
                self.selected_color_container.content.controls = []
                self.selected_color_container.update()

            # Dodanie ikony zatwierdzenia do nowo wybranego kontenera
            self.selected_color_container = e.control
            self.selected_color = e.control.bgcolor  # Zapisanie wybranego koloru
            if self.selected_color_container.content:
                self.selected_color_container.content.controls.append(
                    Container(
                        alignment=alignment.center,
                        content=Icon(
                            icons.CHECK,
                            size=16,
                            color="white",
                        ),
                    )
                )
                self.selected_color_container.update()

            # Automatyczna zmiana koloru tła ostatnio wybranej ikony, jeśli jest wybrana
            if self.last_selected_icon:
                self.last_selected_icon.bgcolor = self.selected_color
                self.last_selected_icon.update()

    def on_icon_click(self, e):
        if self.last_selected_icon:
            # Przywrócenie oryginalnego koloru i usunięcie cienia z ostatnio wybranego kontenera
            self.last_selected_icon.bgcolor = self.last_selected_icon_original_color
            self.last_selected_icon.shadow = None
            self.last_selected_icon.update()

        # Zapisanie referencji do nowo wybranego kontenera i jego oryginalnego koloru
        self.last_selected_icon = e.control
        self.last_selected_icon_original_color = e.control.bgcolor

        # Zmiana koloru nowo wybranego kontenera, jeśli kolor jest wybrany
        if self.selected_color:
            e.control.bgcolor = self.selected_color

        # Dodanie cienia do nowo wybranego kontenera
        e.control.shadow = BoxShadow(
            spread_radius=2,
            blur_radius=10,
            color="white",
            offset=Offset(0, 0)
        )
        e.control.update()

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
            bgcolor="#191E29",
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
                                    RadioGroup(
                                        content=Row(
                                            controls=[
                                                Radio(value="Expenses", label="Expenses", label_style=TextStyle(color=colors.WHITE)),
                                                Radio(value="Income", label="Income", label_style=TextStyle(color=colors.WHITE)),
                                            ],
                                            spacing=50,
                                            alignment="center"
                                        ),
                                    ),
                                    self.InputTextField("Planned expenses", False, self.planned_expenses_input),
                                ]
                            )
                        ]
                    ),

                    Row(
                        alignment="center",
                        controls=[
                            Container(width=30, height=30, bgcolor=colors.RED, border_radius=15, margin=1, on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.GREEN, border_radius=15, margin=1, on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.BLUE, border_radius=15, margin=1, on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.YELLOW, border_radius=15, margin=1, on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.ORANGE, border_radius=15, margin=1, on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.PURPLE, border_radius=15, margin=1, on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.BROWN, border_radius=15, margin=1, on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.PINK, border_radius=15, margin=1, on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
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
                bgcolor="#132D46",
                border_radius=15,
                alignment=alignment.center,
                on_click=self.on_icon_click,
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
            bgcolor="#01C38D",
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
        self.main_col.controls.append(self.main_content_area)

        return self.main_col


def create_categories_page(page: Page):
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
            title=Text('Create categories', color="white"),
            bgcolor="#132D46",
        ),
    )
    page.update()


if __name__ == '__main__':
    flet.app(target=create_categories_page)

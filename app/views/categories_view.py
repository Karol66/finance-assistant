import flet
from flet import *
from app.views.navigation_view import navigate_to, create_navigation_drawer
from app.controllers.category_controller import CategoryController
import app.globals as g


class Expanse(UserControl):

    def __init__(self, user_id):
        super().__init__()
        self.selected_link = None
        self.user_id = user_id
        self.category_controller = CategoryController()

    def on_link_click(self, e, link_name):
        self.selected_link = link_name
        self.update_links()

    def update_links(self):
        for link in self.links:
            link.border = border.only(bottom=border.BorderSide(2, "transparent"))
            if link.data == self.selected_link:
                link.border = border.only(bottom=border.BorderSide(2, "white"))
            link.update()

    def create_category_click(self, e):
        navigate_to(e.page, "Create categories")

    def load_categories(self):
        categories = self.category_controller.get_user_categories(self.user_id)
        for category in categories:
            item_container = Container(
                width=100,
                height=100,
                bgcolor=category["category_color"],
                border_radius=15,
                alignment=alignment.center,
                content=Column(
                    alignment="center",
                    horizontal_alignment="center",
                    controls=[
                        Icon(
                            f"{category['category_icon']}",
                            size=30,
                            color="white",
                        ),
                        Text(f"{category['category_name']}", size=12, color="white", weight="bold"),
                    ]
                )
            )
            self.grid_transfers.controls.append(item_container)

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
            bgcolor="#191E29",
            padding=padding.only(top=10, left=10, right=10),
            content=Column(
                spacing=20,
                controls=[
                    Row(
                        alignment="spaceBetween",
                        vertical_alignment="end",
                        controls=[]
                    ),
                    self.grid_transfers,
                ]
            )
        )

        self.load_categories()

        add_button = Container(
            width=100,
            height=100,
            bgcolor="#01C38D",
            border_radius=15,
            alignment=alignment.center,
            on_click=self.create_category_click,
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

        self.links = [
            Container(
                width=175,
                content=Text(
                    "Expenses",
                    size=18,
                    color=colors.WHITE,
                    weight="bold",
                ),
                on_click=lambda e: self.on_link_click(e, "Expenses"),
                padding=padding.symmetric(horizontal=10, vertical=5),
                data="Expenses",
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

    app = Expanse(user_id=g.logged_in_user["user_id"])

    drawer = create_navigation_drawer(page)
    page.add(
        app,
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

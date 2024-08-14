import flet
from flet import *

from app.controllers.category_controller import CategoryController
from app.controllers.transaction_controller import TransactionController
from app.views.navigation_view import create_navigation_drawer, navigate_to
import app.globals as g


class Expanse(UserControl):
    def __init__(self, user_id):
        super().__init__()
        self.selected_link = None
        self.user_id = user_id
        self.category_controller = CategoryController()
        self.transaction_controller = TransactionController()

    def manage_transaction_click(self, e, transaction_id):
        transaction = self.transaction_controller.get_transaction_by_id(transaction_id)
        g.selected_transaction = transaction
        navigate_to(e.page, "Manage transaction")

    def on_link_click(self, e, link_name):
        self.selected_link = link_name
        self.update_links()
        self.grid_transactions.controls.clear()
        self.load_transactions(link_name)
        self.grid_transactions.update()

    def update_links(self):
        for link in self.links:
            link.border = border.only(bottom=border.BorderSide(2, "transparent"))
            if link.data == self.selected_link:
                link.border = border.only(bottom=border.BorderSide(2, "white"))
            link.update()

    def load_transactions(self, category_type):
        transactions = self.transaction_controller.get_transactions(self.user_id)
        categories = self.category_controller.get_user_categories(self.user_id)

        category_dict = {cat["category_id"]: cat for cat in categories}

        for transaction in transactions:
            category = category_dict.get(transaction["category_id"])
            if category and category["category_type"] == category_type:
                __ = Container(
                    width=100,
                    height=100,
                    bgcolor="#132D46",
                    border_radius=15,
                    alignment=alignment.center,
                    padding=padding.all(13),
                    data=category["category_id"],
                    on_click=lambda e, transaction_id=transaction["transaction_id"]: self.manage_transaction_click(e, transaction_id),
                )
                __.content = Row(
                    alignment="spaceBetween",
                    vertical_alignment="center",
                    spacing=10,
                    controls=[

                        Row(
                            alignment="start",
                            vertical_alignment="center",
                            spacing=20,
                            controls=[
                                Container(
                                    width=40,
                                    height=40,
                                    bgcolor=category['category_color'],
                                    border_radius=20,
                                    alignment=alignment.center,
                                    content=Icon(
                                        f"{category['category_icon']}",
                                        size=20,
                                        color="white",
                                    ),
                                ),
                                Text(
                                    f"{category['category_name']}",
                                    size=16,
                                    color="white54",
                                ),
                            ]
                        ),
                        Text(
                            f"{transaction['amount']}$",
                            size=16,
                            weight="bold",
                            color="white",
                        ),
                    ],
                )
                self.grid_transactions.controls.append(__)

    def build(self):
        self.main_col = Column(
            expand=True,
            alignment="center",
            horizontal_alignment="center",
        )

        self.grid_transactions = GridView(
            expand=True,
            spacing=12,
            runs_count=1,
            max_extent=500,
            child_aspect_ratio=5.0,
        )

        self.main_content_area = Container(
            width=350,
            height=800,
            bgcolor="#191E29",
            padding=padding.only(top=10, left=10, right=10),
            content=Column(
                spacing=20,
                controls=[
                    self.grid_transactions,
                ]
            )
        )

        self.load_transactions("Expenses")

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
                border=border.only(bottom=border.BorderSide(2, "white")),
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


def transaction_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"
    page.scroll = True

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
            title=Text('Transactions', color="white"),
            bgcolor="#132D46",
        ),
    )
    page.update()

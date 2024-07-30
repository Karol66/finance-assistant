import flet
from flet import *

from app.controllers.category_controller import CategoryController
from app.controllers.transaction_controller import TransactionController
from app.views.navigation_view import navigate_to, create_navigation_drawer
import app.globals as g


class Expanse(UserControl):
    def __init__(self, user_id):
        super().__init__()
        self.selected_link = None
        self.user_id = user_id
        self.category_controller = CategoryController()
        self.transaction_controller = TransactionController()

    def click_animation(self, e):
        if e.control.bgcolor == "white10":
            e.control.bgcolor = "white30"
        else:
            e.control.bgcolor = "white10"
        e.control.update()

    def on_link_click(self, e, link_name):
        self.selected_link = link_name
        self.update_links()
        self.grid_categories.controls.clear()
        self.load_transactions(link_name)
        self.update_total_balance()
        self.update_chart(link_name)
        self.grid_categories.update()

    def create_transaction_click(self, e):
        navigate_to(e.page, "Create transaction")

    def update_links(self):
        for link in self.links:
            link.border = border.only(bottom=border.BorderSide(2, "transparent"))
            if link.data == self.selected_link:
                link.border = border.only(bottom=border.BorderSide(2, "white"))
            link.update()

    def load_transactions(self, category_type):
        transactions = self.transaction_controller.get_transactions_by_user_id(self.user_id)
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
                    on_click=lambda e: self.click_animation(e),
                    padding=padding.all(13),
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
                self.grid_categories.controls.append(__)

    def update_total_balance(self):
        transactions = self.transaction_controller.get_transactions_by_user_id(self.user_id)
        total_balance = 0.0

        for transaction in transactions:
            amount = float(transaction["amount"])

            if transaction["category_id"] in [cat["category_id"] for cat in self.category_controller.get_user_categories(self.user_id) if cat["category_type"] == "Income"]:
                total_balance += amount
            else:
                total_balance -= amount

        self.total_balance_amount.value = f"{total_balance:.2f}$"

    def update_chart(self, category_type):
        chart_data = self.transaction_controller.get_chart_data(self.user_id, category_type)
        self.chart.sections.clear()
        total_value = sum(item["value"] for item in chart_data)

        for data in chart_data:
            if total_value > 0:
                percentage = (data["value"] / total_value) * 100
            else:
                percentage = 0

            self.chart.sections.append(
                PieChartSection(
                    value=percentage,
                    title=f"{percentage:.2f}%",
                    title_style=TextStyle(
                        size=16,
                        color="white",
                        weight="bold",
                    ),
                    color=data["color"],
                    radius=50,
                )
            )

    def build(self):
        self.main_col = Column(
            expand=True,
            alignment="center",
            horizontal_alignment="center",
        )

        def on_chart_event(e: PieChartEvent):
            for idx, section in enumerate(self.chart.sections):
                if idx == e.section_index:
                    section.radius = 60
                    section.title_style = TextStyle(size=22, color=colors.WHITE, weight=FontWeight.BOLD,
                                                    shadow=BoxShadow(blur_radius=2, color=colors.BLACK54))
                else:
                    section.radius = 50
                    section.title_style = TextStyle(size=16, color=colors.WHITE, weight=FontWeight.BOLD)
            self.chart.update()

        self.chart = PieChart(
            sections=[],
            sections_space=0,
            center_space_radius=90,
            on_chart_event=on_chart_event,
            expand=True,
        )

        self.total_balance_label = Text(
            "Total Balance:",
            size=18,
            weight="bold",
            color="white"
        )

        self.total_balance_amount = Text(
            "0.00$",
            size=24,
            weight="bold",
            color="white"
        )

        self.update_total_balance()
        self.update_chart("Expenses")

        self.green_container = Container(
            width=350,
            height=700 * 0.55,
            border_radius=30,
            gradient=LinearGradient(
                begin=alignment.top_left,
                end=alignment.bottom_right,
                colors=["#01C38D", "#132D46"],
            ),
            content=Column(
                expand=True,
                alignment=alignment.center,
                horizontal_alignment="center",
                controls=[
                    self.chart,
                    Container(
                        alignment=alignment.center,
                        content=Column(
                            alignment="center",
                            horizontal_alignment="center",
                            controls=[
                                self.total_balance_label,
                                self.total_balance_amount,
                            ],
                        ),
                        margin=margin.only(top=-320)
                    ),
                    Container(
                        width=50,
                        height=50,
                        bgcolor="#FFD700",
                        border_radius=25,
                        alignment=alignment.center,
                        content=Icon(
                            name="add",
                            size=24,
                            color="white"
                        ),
                        margin=margin.only(top=-18, left=280, bottom=20, right=20),
                        on_click=self.create_transaction_click,
                    ),
                ],
            )
        )

        self.grid_categories = GridView(
            expand=True,
            spacing=12,
            runs_count=1,
            max_extent=500,
            child_aspect_ratio=5.0,
        )

        self.main_content_area = Container(
            width=350,
            height=700 * 0.50,
            bgcolor="#191E29",
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
                    self.grid_categories,
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

        self.main_col.controls.append(self.green_container)
        self.main_col.controls.append(self.main_content_area)

        return self.main_col


def dashboard_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"
    page.scroll = True
    page.bgcolor = "#191E29"

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
            title=Text('Dashboard', color="white"),
            bgcolor="#132D46",
        ),
    )
    page.update()
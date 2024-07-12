import flet
from flet import *

from app.views.navigation_view import create_navigation_drawer


class Expanse(UserControl):
    def __init__(self):
        super().__init__()
        self.selected_link = None

    def click_animation(self, e):
        if e.control.bgcolor == "white10":
            e.control.bgcolor = "white30"
        else:
            e.control.bgcolor = "white10"
        e.control.update()

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
        self.main_col = Column(
            expand=True,
            alignment="center",
            horizontal_alignment="center",
        )

        normal_radius = 50
        hover_radius = 60
        normal_title_style = TextStyle(
            size=16, color=colors.WHITE, weight=FontWeight.BOLD
        )
        hover_title_style = TextStyle(
            size=22,
            color=colors.WHITE,
            weight=FontWeight.BOLD,
            shadow=BoxShadow(blur_radius=2, color=colors.BLACK54),
        )

        def on_chart_event(e: PieChartEvent):
            for idx, section in enumerate(chart.sections):
                if idx == e.section_index:
                    section.radius = hover_radius
                    section.title_style = hover_title_style
                else:
                    section.radius = normal_radius
                    section.title_style = normal_title_style
            chart.update()

        chart = PieChart(
            sections=[
                PieChartSection(
                    40,
                    title="40%",
                    title_style=normal_title_style,
                    color=colors.BLUE,
                    radius=normal_radius,
                ),
                PieChartSection(
                    30,
                    title="30%",
                    title_style=normal_title_style,
                    color=colors.YELLOW,
                    radius=normal_radius,
                ),
                PieChartSection(
                    15,
                    title="15%",
                    title_style=normal_title_style,
                    color=colors.PURPLE,
                    radius=normal_radius,
                ),
                PieChartSection(
                    15,
                    title="15%",
                    title_style=normal_title_style,
                    color=colors.GREEN,
                    radius=normal_radius,
                ),
            ],
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
            "$400.00",
            size=24,
            weight="bold",
            color="white"
        )

        self.green_container = Container(
            width=350,
            height=700 * 0.45,
            border_radius=30,
            gradient=LinearGradient(
                begin=alignment.top_left,
                end=alignment.bottom_right,
                colors=["#0f766e", "#064e3b"],
            ),
            content=Column(
                expand=True,
                alignment=alignment.center,
                horizontal_alignment="center",
                controls=[
                    chart,
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
                ],
            )
        )

        self.grid_payments = GridView(
            expand=True,
            spacing=12,
            runs_count=1,
            max_extent=500,
            child_aspect_ratio=5.0,
        )

        self.main_content_area = Container(
            width=350,
            height=700 * 0.50,
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

        image_path = "./assets/icon.png"

        payment_list = [
            ["Utilites", "$100.25", ],
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
                on_click=lambda e: self.click_animation(e),
                padding=padding.all(20),
            )
            __.content = Row(
                alignment="spaceBetween",
                vertical_alignment="center",
                spacing=10,
                controls=[
                    Row(
                        alignment="start",
                        vertical_alignment="center",
                        spacing=10,
                        controls=[
                            Image(
                                src=image_path,
                                width=30,
                                height=30,
                            ),
                            Text(
                                f"{i[0]}",
                                size=16,
                                color="white54",
                            ),
                        ]
                    ),
                    Text(
                        f"{i[1]}",
                        size=16,
                        weight="bold",
                        color="white",
                    ),
                ],
            )
            self.grid_payments.controls.append(__)

        self.links = [
            Container(
                width=175,
                content=Text(
                    "Revenue",
                    size=18,
                    color=colors.WHITE,
                    weight="bold",
                ),
                on_click=lambda e: self.on_link_click(e, "Revenue"),
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

        self.main_col.controls.append(self.green_container)
        self.main_col.controls.append(self.main_content_area)

        return self.main_col


def dashboard_page(page: Page):
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
            title=Text('Dashboard', color="white"),
            bgcolor="black",
        ),
    )
    page.update()

import flet
import flet as ft
from flet import *
from navigation import create_navigation_drawer

class Expanse(UserControl):
    def click_animation(self, e):
        if e.control.bgcolor == "white10":
            e.control.bgcolor = "white30"
        else:
            e.control.bgcolor = "white10"
        e.control.update()

    def build(self):
        self.main_col = Column(
            expand=True,
        )

        normal_radius = 50
        hover_radius = 60
        normal_title_style = ft.TextStyle(
            size=16, color=ft.colors.WHITE, weight=ft.FontWeight.BOLD
        )
        hover_title_style = ft.TextStyle(
            size=22,
            color=ft.colors.WHITE,
            weight=ft.FontWeight.BOLD,
            shadow=ft.BoxShadow(blur_radius=2, color=ft.colors.BLACK54),
        )

        def on_chart_event(e: ft.PieChartEvent):
            for idx, section in enumerate(chart.sections):
                if idx == e.section_index:
                    section.radius = hover_radius
                    section.title_style = hover_title_style
                else:
                    section.radius = normal_radius
                    section.title_style = normal_title_style
            chart.update()

        chart = ft.PieChart(
            sections=[
                ft.PieChartSection(
                    40,
                    title="40%",
                    title_style=normal_title_style,
                    color=ft.colors.BLUE,
                    radius=normal_radius,
                ),
                ft.PieChartSection(
                    30,
                    title="30%",
                    title_style=normal_title_style,
                    color=ft.colors.YELLOW,
                    radius=normal_radius,
                ),
                ft.PieChartSection(
                    15,
                    title="15%",
                    title_style=normal_title_style,
                    color=ft.colors.PURPLE,
                    radius=normal_radius,
                ),
                ft.PieChartSection(
                    15,
                    title="15%",
                    title_style=normal_title_style,
                    color=ft.colors.GREEN,
                    radius=normal_radius,
                ),
            ],
            sections_space=0,
            center_space_radius=90,
            on_chart_event=on_chart_event,
            expand=True,
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
                controls=[chart],
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

        self.main_col.controls.append(self.green_container)
        self.main_col.controls.append(self.main_content_area)

        return self.main_col

def main(page: Page):
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

if __name__ == '__main__':
    flet.app(target=main)

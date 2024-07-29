import time
import flet
from flet import *
from app.views.navigation_view import create_navigation_drawer
import locale

locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')

class BaseChar(LineChart):
    def __init__(self, line_color: str):
        self.points: list = []
        super().__init__(
            expand=True,
            tooltip_bgcolor=colors.with_opacity(0.8, colors.WHITE),
            left_axis=ChartAxis(labels_size=50),
            bottom_axis=ChartAxis(labels_interval=1, labels_size=40),
            horizontal_grid_lines=ChartGridLines(
                interval=10,
                color=colors.with_opacity(0.2, colors.ON_SURFACE),
                width=1,
            ),
        )

        self.line = LineChartData(
            color=line_color,
            stroke_width=2,
            curved=True,
            stroke_cap_round=True,
            below_line_gradient=LinearGradient(
                begin=alignment.top_center,
                end=alignment.bottom_center,
                colors=[
                    colors.with_opacity(0.25, line_color),
                    "transparent",
                ],
            ),
        )

        self.line.data_points = self.points
        self.data_series = [self.line]

    def create_data_points(self, x, y):
        self.points.append(
            LineChartDataPoint(
                x, y,
                selected_below_line=ChartPointLine(
                    width=0.5,
                    color="white54",
                    dash_pattern=[2, 4],
                ),
                selected_point=ChartCirclePoint(stroke_width=1)
            ),
        )
        self.update_axes()
        self.update()

    def update_axes(self):
        if not self.points:
            return

        min_x = min(p.x for p in self.points)
        max_x = max(p.x for p in self.points)
        min_y = min(p.y for p in self.points)
        max_y = max(p.y for p in self.points)

        self.left_axis = ChartAxis(
            labels=[
                ChartAxisLabel(value=i, label=Text(f"{i}", color=colors.WHITE))
                for i in range(int(min_y), int(max_y) + 1)
            ],
            labels_size=50
        )
        self.bottom_axis = ChartAxis(
            labels=[
                ChartAxisLabel(value=i, label=Text(f"{i}", color=colors.WHITE))
                for i in range(int(min_x), int(max_x) + 1)
            ],
            labels_interval=1,
            labels_size=40
        )


in_style: dict = {
    "expand": 1,
    "bgcolor": "#17181d",
    "border_radius": 10,
    "padding": 30,
}

class GraphIn(flet.Container):
    def __init__(self):
        super().__init__(**in_style)
        self.chart = BaseChar(line_color="teal600")
        self.content = self.chart


out_style: dict = {
    "expand": 1,
    "bgcolor": "#17181d",
    "border_radius": 10,
    "padding": 30,
}

class GraphOut(flet.Container):
    def __init__(self):
        super().__init__(**out_style)
        self.chart = BaseChar(line_color="red500")
        self.content = self.chart


tracker_style: dict = {
    "main": {
        "expand": True,
        "bgcolor": "#17181d",
        "border_radius": 10,
    },
    "balance": {
        "size": 48,
        "weight": "bold",
    },
    "input": {
        "width": 220,
        "height": 40,
        "border_color": "white12",
        "cursor_height": 16,
        "cursor_color": "white12",
        "content_padding": 10,
        "text_align": "center",
    },
    "add": {
        "icon": icons.ADD,
        "bgcolor": "#1f2128",
        "icon_size": 16,
        "icon_color": "teal600",
        "scale": transform.Scale(0.8),
    },
    "subtract": {
        "icon": icons.REMOVE,
        "bgcolor": "#1f2128",
        "icon_size": 16,
        "icon_color": "red600",
        "scale": transform.Scale(0.8),
    },
    "data_table": {
        "columns": [
            DataColumn(Text("Timestamp", weight="w900", color="white")),
            DataColumn(Text("Amount", weight="w900", color="white"), numeric=True),
        ],
        "width": 380,
        "heading_row_height": 35,
        "data_row_max_height": 40,
    },
    "data_table_container": {
        "expand": True,
        "width": 450,
        "padding": 10,
        "border_radius": border_radius.only(top_left=10, top_right=10),
        "shadow": BoxShadow(
            spread_radius=8,
            blur_radius=15,
            color=colors.with_opacity(0.15, "black"),
            offset=Offset(4, 4),
        ),
        "bgcolor": colors.with_opacity(0.75, "#1f2128"),
    },
}

class Tracker(Container):
    def __init__(self, _in: object, _out: object):
        super().__init__(**tracker_style.get("main"))
        self._in: object = _in
        self._out: object = _out

        self.counter = 0.0
        self.balance = Text(
            locale.currency(self.counter, grouping=True),
            **tracker_style.get("balance"),
            color="white",
        )

        self.input = TextField(
            **tracker_style.get("input"),
            color="white"
        )

        self.add = IconButton(
            **tracker_style.get("add"),
            data=True,
            on_click=lambda e: self.update_balance(e),
        )
        self.subtract = IconButton(
            **tracker_style.get("subtract"),
            data=False,
            on_click=lambda e: self.update_balance(e),
        )

        self.table = DataTable(
            **tracker_style.get("data_table"),
        )

        self.content = Column(
            horizontal_alignment="center",
            controls=[
                Divider(height=15, color="transparent"),
                Text(
                    "Total Balance",
                    size=11,
                    weight="w900",
                    color="white",
                ),
                Row(
                    alignment="center",
                    controls=[
                        self.balance,
                    ]
                ),
                Divider(height=15, color="transparent"),
                Row(
                    alignment="center",
                    controls=[
                        self.subtract,
                        self.input,
                        self.add,
                    ],
                ),
                Divider(height=25, color="transparent"),
                Container(
                    **tracker_style.get("data_table_container"),
                    content=Column(
                        expand=True,
                        scroll="hidden",
                        controls=[
                            self.table,
                        ]
                    )
                )
            ],
        )

        self.x = 0

    def update_data_table(self, amount: float, sign: bool):
        timestamp = int(time.time())
        data = DataRow(
            cells=[
                DataCell(
                    Text(
                        timestamp,
                        color="white",
                    ),
                ),
                DataCell(
                    Text(
                        locale.currency(amount, grouping=True),
                        color="teal" if sign else "red",

                    ),
                ),
            ]
        )

        self.table.rows.append(data)
        self.update()

        return timestamp

    def update_balance(self, event):
        if self.input.value != "" and self.input.value.isdigit():
            delta: float = float(self.input.value)

            if event.control.data:
                self.counter += delta
                self.update_data_table(delta, sign=True)

                self._in.chart.create_data_points(
                    x=self.x,
                    y=delta,
                )

                self.x += 1
            else:
                self.counter -= delta
                self.update_data_table(delta, sign=False)

                self._out.chart.create_data_points(
                    x=self.x,
                    y=delta,
                )

                self.x += 1

            if self.counter < 0:
                formatted_balance = f"-${abs(self.counter):,.2f}"
            else:
                formatted_balance = f"${self.counter:,.2f}"

            self.balance.value = formatted_balance
            self.balance.update()
            self.input.value = ""
            self.input.update()

def statistic_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"
    page.scroll = True

    graph_in: Container = GraphIn()
    graph_out: Container = GraphOut()
    tracker: Container = Tracker(_in=graph_in, _out=graph_out)

    drawer = create_navigation_drawer(page)

    page.add(
        Row(
            expand=True,
            controls=[
                tracker,
                Column(
                    expand=True,
                    controls=[
                        graph_in,
                        graph_out,
                    ]
                )
            ]
        ),
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
            title=Text('Statistic', color="white"),
            bgcolor="#132D46",
        ),
    )
    page.update()


if __name__ == '__main__':
    flet.app(target=statistic_page)

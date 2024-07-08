import flet
from flet import *
from navigation import create_navigation_drawer
import locale

locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')

in_style: dict = {
    "expand": 1,
    "bgcolor": "#17181d",
    "border_radius": 10,
    "padding": 30,
}


class GraphIn(flet.Container):
    def __init__(self):
        super().__init__(**in_style)


out_style: dict = {
    "expand": 1,
    "bgcolor": "#17181d",
    "border_radius": 10,
    "padding": 30,
}


class GraphOut(flet.Container):
    def __init__(self):
        super().__init__(**out_style)


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
            DataColumn(Text("Timestamp", weight="w900")),
            DataColumn(Text("Amount", weight="w900"), numeric=True),
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
        )

        self.add = IconButton(
            **tracker_style.get("add"),
            data=True,
        )
        self.subtract = IconButton(
            **tracker_style.get("subtract"),
            data=False,
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
                )
            ],
        )


def statistic_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"

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
            bgcolor="black",
        ),
    )
    page.update()


if __name__ == '__main__':
    flet.app(target=statistic_page)

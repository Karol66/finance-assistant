import flet
from flet import *

from app.controllers.card_controller import CardController  # Updated import
from app.views.navigation_view import navigate_to, create_navigation_drawer
import app.globals as g

class Expanse(UserControl):
    def __init__(self, user_id):
        super().__init__()
        self.selected_link = None
        self.user_id = user_id
        self.card_controller = CardController()  # Initialize CardController
        self.ColorCount = 0  # Initialize ColorCount for card colors

    def card_click(self, e, card_id):
        card = self.card_controller.get_card_by_id(card_id)
        g.selected_card = card  # Update the global selected card
        navigate_to(e.page, "Manage card")  #

    def create_card_click(self, e):
        navigate_to(e.page, "Create card")

    def load_cards(self):  # Renamed method
        cards = self.card_controller.get_user_cards(self.user_id)  # Fetch cards

        for card in cards:
            # Customize the card layout
            card_container = Card(
                content=Container(
                    content=(
                        Column(
                            controls=[
                                Row(
                                    alignment="spaceBetween",
                                    controls=[
                                        Column(
                                            spacing=1,
                                            controls=[
                                                Container(
                                                    alignment=alignment.bottom_left,
                                                    content=Text(
                                                        "BANK NAME",
                                                        color="white",
                                                        size=9,
                                                        weight="w500",
                                                    ),
                                                ),
                                                Container(
                                                    alignment=alignment.top_left,
                                                    content=Text(
                                                        card['card_name'],
                                                        color="#e2e8f0",
                                                        size=20,
                                                        weight="w700",
                                                    ),
                                                ),
                                            ],
                                        ),
                                        Icon(
                                            name=icons.SETTINGS_OUTLINED,
                                            size=16,
                                            color=colors.WHITE
                                        ),
                                    ],
                                ),
                                Container(
                                    padding=padding.only(
                                        top=10,
                                        bottom=20,
                                    ),
                                ),
                                Row(
                                    alignment="spaceBetween",
                                    controls=[
                                        Column(
                                            spacing=1,
                                            controls=[
                                                Container(
                                                    alignment=alignment.bottom_left,
                                                    content=Text(
                                                        "CARD NUMBER",
                                                        color="white",
                                                        size=9,
                                                        weight="w500",
                                                    ),
                                                ),
                                                Container(
                                                    alignment=alignment.top_left,
                                                    content=Text(
                                                        f"**** **** **** {card['card_number'][-4:]}",
                                                        # Display last 4 digits
                                                        color="#e2e8f0",
                                                        size=15,
                                                        weight="w700",
                                                    ),
                                                ),
                                                Container(
                                                    bgcolor="#191E29",  # Ensure consistent background
                                                    padding=padding.only(
                                                        bottom=5,
                                                    ),
                                                ),
                                                Container(
                                                    alignment=alignment.bottom_left,
                                                    content=Text(
                                                        "CVV NUMBER",
                                                        color="white",
                                                        size=9,
                                                        weight="w500",
                                                    ),
                                                ),
                                                Container(
                                                    alignment=alignment.top_left,
                                                    content=Text(
                                                        f"**{card['cvv'][-1:]}",  # Display last digit of CVV
                                                        color="#e2e8f0",
                                                        size=13,
                                                        weight="w700",
                                                    ),
                                                ),
                                            ],
                                        ),
                                        Column(
                                            horizontal_alignment="end",
                                            controls=[
                                                Image(
                                                    src="./app/assets/icon.png",  # Path to your icon
                                                    width=80,
                                                    height=80,
                                                    fit="contain",
                                                )
                                            ],
                                        ),
                                    ],
                                ),
                            ]
                        )
                    ),
                    padding=padding.all(12),
                    margin=margin.all(-5),
                    width=310,
                    height=185,
                    border_radius=border_radius.all(18),
                    gradient=self.gradient_generator(
                        ColorList.CARDCOLORS["from"][self.ColorCount % len(ColorList.CARDCOLORS["from"])],
                        ColorList.CARDCOLORS["to"][self.ColorCount % len(ColorList.CARDCOLORS["to"])],
                    ),
                    on_click=lambda e, card_id=card["card_id"]: self.card_click(e, card_id),
                )
            )
            self.grid_cards.controls.append(card_container)  # Update to grid_cards
            self.ColorCount += 1  # Increment color count for the next card


    def build(self):
        self.main_col = Column(
            expand=True,
            alignment="center",
            horizontal_alignment="center",
        )

        self.grid_cards = GridView(  # Update to grid_cards
            expand=True,
            spacing=12,
            runs_count=1,
            max_extent=500,
            child_aspect_ratio=1.75,
        )

        self.main_content_area = Container(
            width=350,
            height=615,
            bgcolor="#191E29",
            padding=padding.only(top=10, left=10, right=10),
            content=Column(
                spacing=10,
                expand=True,
                alignment="start",
                horizontal_alignment="center",
                controls=[
                    Container(
                        content=Column(
                            alignment="center",
                            horizontal_alignment="center",
                            spacing=0,
                            controls=[

                            ],
                        ),
                    ),
                    self.grid_cards,  # Update to grid_cards
                ]
            )
        )

        self.load_cards()  # Call load_cards

        self.main_col.controls.append(self.main_content_area)

        self.main_col.controls.append(Container(
            width=60,
            height=60,
            bgcolor="yellow",
            border_radius=30,
            alignment=alignment.center,
            content=Icon(
                icons.ADD,
                size=40,
                color="black",
            ),
            on_click=self.create_card_click  # Ensure this navigates correctly
        ))

        return self.main_col

    def gradient_generator(self, start, end):
        return LinearGradient(
            begin=alignment.bottom_left,
            end=alignment.top_right,
            colors=[
                start,
                end,
            ],
        )

class ColorList:
    BACKGROUND = {
        "from": "#134e4a",
        "to": "#14b8a6",
    }

    WALLITE = {
        "from": "#1f2937",
        "to": "#111827",
    }

    CARDCOLORS = {
        "from": [
            "#475569",
            "#047857",
            "#3f3f46",
            "#6d28d9",
            "#0f766e",
            "#0e7490",
            "#334155",
            "#7dd3fc",
        ],
        "to": [
            "#0f172a",
            "#064e3b",
            "#18181b",
            "#581c87",
            "#134e4a",
            "#164e63",
            "#0f172a",
            "#0c4a6e",
        ],
    }

def card_page(page: Page):
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
            title=Text('Cards', color="white"),
            bgcolor="#132D46",
        ),
    )

    page.update()

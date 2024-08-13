from flet import *

from app.controllers.account_controller import AccountController
from app.controllers.card_controller import CardController
from app.views.navigation_view import create_navigation_drawer
import app.globals as g


class Expanse(UserControl):

    def __init__(self, user_id, account_id):
        super().__init__()
        self.selected_link = None
        self.selected_color_container = None
        self.selected_color = None
        self.last_selected_icon = None
        self.last_selected_icon_original_color = None
        self.selected_icon = None
        self.account_controller = AccountController()
        self.card_controller = CardController()
        self.user_id = user_id
        self.account_id = account_id

        self.account_data = g.selected_account
        self.account_name = self.account_data.get("account_name", "")
        self.account_type = self.account_data.get("account_type", "")
        self.balance = self.account_data.get("balance", "")
        self.account_color = self.account_data.get("account_color", colors.GREY)
        self.account_icon = self.account_data.get("account_icon", icons.MORE_HORIZ)
        self.card_id = self.account_data.get("card_id", "0")
        self.include_in_total = self.account_data.get("include_in_total", "1")

        self.loaded_icon_container = None

    def InputTextField(self, text: str, hide: bool, ref, width="100%", value=""):
        return Container(
            alignment=alignment.center,
            content=TextField(
                height=58,
                width=width,
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
                value=value,
            ),
        )

    # TODO uproscic
    def on_color_click(self, e):
        if self.selected_color_container == e.control:
            # Odznacz aktualnie wybrany kontener
            self.selected_color_container.content.controls = []
            self.selected_color_container.update()
            self.selected_color_container = None
            self.selected_color = None
        else:
            if self.selected_color_container:
                # Usuń ikonę z wcześniej wybranego kontenera
                self.selected_color_container.content.controls = []
                self.selected_color_container.update()

            # Dodaj ikonę do nowo wybranego kontenera
            self.selected_color_container = e.control
            self.selected_color = e.control.bgcolor  # Zapisz wybrany kolor
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

            # Zastosuj logikę zmiany koloru tutaj
            if self.last_selected_icon:
                self.last_selected_icon.bgcolor = self.selected_color
                self.last_selected_icon.update()
            else:
                # Zmień kolor załadowanej ikony, jeśli nie wybrano żadnej ikony
                if self.loaded_icon_container:
                    self.loaded_icon_container.bgcolor = self.selected_color
                    self.loaded_icon_container.update()

    def on_icon_click(self, e):
        # Przywróć kolor tła załadowanej ikony z bazy danych
        if self.loaded_icon_container and self.loaded_icon_container != e.control:
            self.loaded_icon_container.bgcolor = "#132D46"
            self.loaded_icon_container.border = None
            self.loaded_icon_container.update()

        if self.last_selected_icon:
            # Przywróć oryginalny kolor tła i usuń obramowanie z ostatnio wybranego kontenera
            self.last_selected_icon.bgcolor = "#132D46"
            self.last_selected_icon.border = None
            self.last_selected_icon.update()

        # Zapisanie referencji do nowo wybranego kontenera i jego oryginalnego koloru
        self.last_selected_icon = e.control
        self.last_selected_icon_original_color = e.control.bgcolor

        # Zmień kolor tła nowo wybranego kontenera, jeśli wybrano kolor
        if self.selected_color:
            e.control.bgcolor = self.selected_color

        # Dodaj obramowanie do nowo wybranego kontenera
        e.control.border = border.all(4, colors.WHITE)
        e.control.update()

        # Zapisz wybraną ikonę
        self.selected_icon = e.control.data

    def update_account(self, e):

        account_name = self.account_name_input.current.value
        account_type = self.account_type_selection.value
        balance = self.balance_input.current.value
        account_color = self.selected_color
        # Użyj wybranej ikony, jeśli istnieje, w przeciwnym razie użyj ikony z bazy danych
        account_icon = self.selected_icon if self.selected_icon else self.account_icon
        card_id = self.card_selection.value
        include_in_total = self.include_in_total_switch.current.value

        self.account_controller.update_account(self.account_id, self.user_id, account_name, account_type, balance,
                                               account_color, account_icon, card_id, include_in_total)
        print("Account updated successfully")

    def delete_account(self, e):
        self.account_controller.delete_account(self.account_id, self.user_id)
        print("Account deleted successfully")

    def build(self):
        self.balance_input = Ref[TextField]()
        self.account_name_input = Ref[TextField]()
        self.include_in_total_switch = Ref[Switch]()

        self.currency_selection = Dropdown(
            options=[
                dropdown.Option("Currency 1"),
                dropdown.Option("Currency 2"),
                dropdown.Option("Currency 3")
            ],
            label="Select currency",
            width="100%",
            bgcolor=colors.WHITE,
            color=colors.BLACK
        )

        self.account_type_selection = Dropdown(
            options=[
                dropdown.Option("Savings"),
                dropdown.Option("Checking"),
                dropdown.Option("Credit")
            ],
            label="Select account type",
            width="100%",
            bgcolor=colors.WHITE,
            color=colors.BLACK,
            value=self.account_type,
        )

        user_cards = self.card_controller.get_user_cards(self.user_id)
        self.card_selection = Dropdown(
            options=[dropdown.Option(card["card_id"], card["card_name"]) for card in user_cards],
            label="Select card",
            width="100%",
            bgcolor=colors.WHITE,
            color=colors.BLACK,
            value=self.card_id,
        )

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
            height=930,
            bgcolor="#191E29",
            padding=padding.only(top=10, left=10, right=10, bottom=10),
            content=Column(
                spacing=20,
                controls=[
                    Container(
                        width=400,
                        content=Column(
                            spacing=10,
                            controls=[
                                self.InputTextField("Balance", False, self.balance_input, width="100%",
                                                    value=self.balance),
                                self.InputTextField("Account name", False, self.account_name_input, width="100%",
                                                    value=self.account_name),
                                self.currency_selection,
                                # opakowne żeby był jednakowy odstep w polach w formularzu
                                Container(
                                    margin=margin.only(top=10),
                                    content=self.account_type_selection,
                                ),
                                Container(
                                    margin=margin.only(top=10, bottom=10),
                                    content=self.card_selection,
                                ),
                                Container(
                                    alignment=alignment.center_left,
                                    content=Row(
                                        controls=[
                                            Text(
                                                "Do not include in the total account",
                                                color="white",
                                            ),
                                            Switch(ref=self.include_in_total_switch, value=self.include_in_total),

                                        ]
                                    ),
                                )
                            ]
                        )

                    ),

                    Row(
                        alignment="center",
                        wrap=True,
                        controls=[
                            Container(width=30, height=30, bgcolor=colors.RED, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.GREEN, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.BLUE, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.YELLOW, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.ORANGE, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.PURPLE, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.BROWN, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.PINK, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
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

                    Container(
                        alignment=alignment.center,
                        content=ElevatedButton(
                            content=Text(
                                "Update",
                                size=14,
                                weight="bold",
                            ),
                            bgcolor="yellow",
                            color="white",
                            style=ButtonStyle(
                                shape={
                                    "": RoundedRectangleBorder(radius=8)
                                },
                            ),
                            height=58,
                            width=300,
                            on_click=self.update_account
                        )
                    ),

                    Container(
                        alignment=alignment.center,
                        content=ElevatedButton(
                            content=Text(
                                "Delete",
                                size=14,
                                weight="bold",
                            ),
                            bgcolor="red",
                            color="white",
                            style=ButtonStyle(
                                shape={
                                    "": RoundedRectangleBorder(radius=8)
                                },
                            ),
                            height=58,
                            width=300,
                            on_click=self.delete_account
                        )
                    )
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
            [icons.TRAVEL_EXPLORE],
        ]

        for i in icon_list:
            icon_bgcolor = self.account_color if i[0] == self.account_icon else "#132D46"
            icon_border = border.all(4, colors.WHITE) if i[0] == self.account_icon else None

            item_container = Container(
                width=100,
                height=100,
                bgcolor=icon_bgcolor,
                border_radius=15,
                alignment=alignment.center,
                on_click=self.on_icon_click,
                data=i[0],  # Dodaje nazwę ikony jako dane do kontenera
                border=icon_border,
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

            # Przechowaj referencję do ikony załadowanej z bazy danych
            if i[0] == self.account_icon:
                self.loaded_icon_container = item_container

            self.grid_transfers.controls.append(item_container)

        self.main_col.controls.append(self.main_content_area)

        return self.main_col


def manage_account_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"
    page.scroll = True

    app = Expanse(user_id=g.logged_in_user["user_id"], account_id=g.selected_account["account_id"])

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
            title=Text('Manage account', color="white"),
            bgcolor="#132D46",
        ),
    )
    page.update()

import datetime
import flet
from flet import *

from app.controllers.card_controller import CardController
from app.views.navigation_view import create_navigation_drawer
import app.globals as g


class Expanse(UserControl):

    def __init__(self, user_id, card_id):
        super().__init__()
        self.selected_link = None
        self.selected_color_container = None
        self.selected_color = None
        self.last_selected_icon = None
        self.last_selected_icon_original_color = None
        self.selected_icon = None
        self.card_controller = CardController()
        self.user_id = user_id
        self.card_id = card_id

        self.card_data = g.selected_card
        self.card_name = self.card_data.get("card_name", "")
        self.card_number = self.card_data.get("card_number", "")
        self.cvv = self.card_data.get("cvv", "")
        self.card_type = self.card_data.get("card_type", None)
        self.balance = self.card_data.get("balance", "")

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


    def update_card(self, e):
        card_name = self.card_name_input.current.value
        card_number = self.card_number_input.current.value
        cvv = self.cvv_input.current.value
        card_type = self.card_type_selection.value
        balance = self.balance_input.current.value

        # Add the category using the service
        self.card_controller.update_card( self.card_id, self.user_id, card_name, card_number, cvv,
                                                 card_type, balance)
        print("Card updated successfully")

    def delete_card(self, e):
        self.card_controller.delete_card( self.card_id, self.user_id)
        print("Card deleted successfully")

    def build(self):
        self.card_name_input = Ref[TextField]()
        self.card_number_input = Ref[TextField]()
        self.cvv_input = Ref[TextField]()
        self.balance_input = Ref[TextField]()

        self.card_type_selection = Dropdown(
            options=[
                dropdown.Option("Debit Card"),
                dropdown.Option("Credit Card"),
                dropdown.Option("Prepaid Card"),
                dropdown.Option("Charge Card"),
                dropdown.Option("Virtual Card"),
                dropdown.Option("Loyalty Card"),
                dropdown.Option("Corporate Card"),
            ],
            label="Select card type",
            width="100%",
            bgcolor=colors.WHITE,
            color=colors.BLACK,
            value=self.card_type,
        )

        self.main_col = Column(
            expand=True,
            alignment="center",
            horizontal_alignment="center",
        )

        self.main_content_area = Container(
            width=400,
            height=720,
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
                                self.InputTextField("Card name", False, self.card_name_input, width="100%", value=self.card_name),
                                self.InputTextField("Card number", False, self.card_number_input, width="100%", value=self.card_number),
                                self.InputTextField("CVV", False, self.cvv_input, width="100%", value=self.cvv),
                                Container(
                                    margin=margin.only(top=10, bottom=10),
                                    content=self.card_type_selection,
                                ),
                                self.InputTextField("Balance", False, self.balance_input, width="100%", value=self.balance),
                            ]
                        )

                    ),

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
                            on_click=self.update_card
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
                            on_click=self.delete_card
                        )
                    )
                ]
            )
        )

        self.main_col.controls.append(self.main_content_area)

        return self.main_col


def manage_card_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"
    page.scroll = True

    app = Expanse(user_id=g.logged_in_user["user_id"], card_id=g.selected_card["card_id"])

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
            title=Text('Manage card', color="white"),
            bgcolor="#132D46",
        ),
    )
    page.update()

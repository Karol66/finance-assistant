import flet
import asyncio
from flet import *
from app.controllers.account_controller import AccountController
import clipboard
import app.globals as g

from app.views.navigation_view import create_navigation_drawer


class WalletApp(UserControl):
    def __init__(self, user_id):
        super().__init__()
        self.user_id = user_id
        self.account_controller = AccountController()
        self.snack = SnackBar(Text("Number copied!"))
        self.HeightCount = 25
        self.ColorCount = 0
        self.CardCount = 0
        self.DataDict = {}

    def build(self):
        self.CardList = Column(
            alignment="start",
            spacing=25,
        )

        self.ImportButton = IconButton(
            icon=icons.DOWNLOAD,
            icon_color=colors.WHITE,
            icon_size=16,
            on_click=lambda e: asyncio.run(self.load_accounts()),
        )

        self.InsertButton = IconButton(
            icon=icons.ADD,
            icon_color=colors.WHITE,
            icon_size=16,
            on_click=lambda e: self.open_entry_form(),
            disabled=True,
        )

        self.WalletContainer = Container(
            alignment=alignment.center_right,
            padding=padding.only(right=200),
            content=Card(
                elevation=15,
                content=Container(
                    content=Column(
                        scroll="auto",
                        alignment="start",
                        spacing=25,
                        controls=[
                            self.snack,
                            Row(
                                alignment="spaceBetween",
                                controls=[
                                    Text(
                                        "Wallet",
                                        color="white",
                                        size=20,
                                        weight="bold",
                                    ),
                                    Container(
                                        content=Row(
                                            spacing=0,
                                            tight=True,
                                            alignment="end",
                                            controls=[
                                                self.InsertButton,
                                                self.ImportButton,
                                            ],
                                        )
                                    ),
                                ],
                            ),
                            Container(
                                content=Column(
                                    controls=[
                                        self.CardList,
                                    ],
                                ),
                            ),
                        ],
                    ),
                    width=360,
                    height=580,
                    padding=padding.all(20),
                    alignment=alignment.top_center,
                    border_radius=border_radius.all(15),
                    gradient=LinearGradient(
                        begin=alignment.bottom_left,
                        end=alignment.top_right,
                        colors=[
                            ColorList.WALLITE["from"], ColorList.WALLITE["to"]
                        ],
                    ),
                ),
            ),
        )

        return Container(
            content=(
                Column(
                    alignment="center",
                    controls=[
                        self.EntryForm(),
                        self.WalletContainer,
                    ],
                )
            ),
            width=900,
            height=800,
            margin=margin.all(-10),
            gradient=self.GradientGenerator(ColorList.BACKGROUND["from"], ColorList.BACKGROUND["to"]),
            alignment=alignment.center,
        )

    def open_entry_form(self):
        self.dialog = self.EntryForm
        self.EntryForm.open = True
        self.update()

    def EntryForm(self):
        self.BankName = TextField(
            label="Card Name",
            border="underline",
            text_size=12,
        )

        self.CardNumber = TextField(
            label="Card Number",
            border="underline",
            text_size=12,
        )

        self.CardCVV = TextField(
            label="Card CVV",
            border="underline",
            text_size=12,
        )

        self.EntryForm = AlertDialog(
            title=Text(
                "Enter Your Bank Name\nCard Number",
                text_align="center",
                size=12,
            ),
            content=Column(
                [
                    self.BankName,
                    self.CardNumber,
                    self.CardCVV,
                ],
                spacing=15,
                height=280,
            ),
            actions=[
                TextButton("Insert", on_click=lambda e: self.check_entry_form()),
                TextButton("Cancel", on_click=lambda e: self.cancel_entry_form()),
            ],
            actions_alignment="center",
            on_dismiss=lambda e: self.cancel_entry_form(),
        )

        return self.EntryForm

    def cancel_entry_form(self):
        self.BankName.value, self.CardNumber.value, self.CardCVV.value = (
            None,
            None,
            None,
        )

        self.CardNumber.error_text, self.BankName.error_text, self.CardCVV.error_text = (
            None,
            None,
            None,
        )

        self.EntryForm.open = False
        self.update()

    def check_entry_form(self):
        if len(self.CardNumber.value) == 0:
            self.CardNumber.error_text = "Please enter your card number!"
            self.update()
        else:
            self.CardNumber.error_text = None
            self.update()

        if len(self.BankName.value) == 0:
            self.BankName.error_text = "Please enter your bank name!"
            self.update()
        else:
            self.BankName.error_text = None
            self.update()

        if len(self.CardCVV.value) == 0:
            self.CardCVV.error_text = "Please enter your card CVV!"
            self.update()
        else:
            self.CardCVV.error_text = None
            self.update()

        if (
                len(self.CardNumber.value) &
                len(self.BankName.value) &
                len(self.CardCVV.value) != 0
        ):
            asyncio.run(self.insert_data_into_database())
            self.card_generator(
                self.BankName.value, self.CardNumber.value, self.CardCVV.value
            )

    async def insert_data_into_database(self):
        self.account_controller.create_account(
            self.user_id, self.BankName.value, "Card", 0.0
        )

    async def load_accounts(self):
        accounts = self.account_controller.get_user_accounts(self.user_id)
        for account in accounts:
            self.card_generator(account['account_name'], account['account_type'], str(account['balance']))

        self.ImportButton.disabled = True
        self.InsertButton.disabled = False
        self.update()

    def card_generator(self, bank, number, cvv):
        self.img = Image(
            src="./app/assets/icon.png",
            width=80,
            height=80,
            fit="contain",
        )

        self.bank = bank
        self.number = number
        self.cvv = cvv

        self.DataDict[self.CardCount] = {"number": f"{self.number}", "cvv": f"{self.cvv}"}

        self.CardTest = Card(
            elevation=20,
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
                                                    self.bank,
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
                                                    f"**** **** **** {self.number[-4:]}",
                                                    color="#e2e8f0",
                                                    size=15,
                                                    weight="w700",
                                                ),
                                                data={self.DataDict[self.CardCount]["number"]},
                                                on_click=lambda e: self.get_value(e),
                                            ),
                                            Container(
                                                bgcolor="pink",
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
                                                    f"**{self.cvv[-1:]}",
                                                    color="#e2e8f0",
                                                    size=13,
                                                    weight="w700",
                                                ),
                                                data=self.DataDict[self.CardCount]["cvv"],
                                                on_click=lambda e: self.get_value(e),
                                            ),
                                        ],
                                    ),
                                    Column(
                                        horizontal_alignment="end",
                                        controls=[self.img],
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
                gradient=self.GradientGenerator(
                    ColorList.CARDCOLORS["from"][self.ColorCount % len(ColorList.CARDCOLORS["from"])],
                    ColorList.CARDCOLORS["to"][self.ColorCount % len(ColorList.CARDCOLORS["to"])],
                ),
            )
        )

        self.CardCount += 1
        self.ColorCount += 1
        self.HeightCount += 50

        self.CardList.controls.append(self.CardTest)
        self.cancel_entry_form()
        self.update()

    def get_value(self, e):
        clipboard.copy(e.control.data)
        self.snack.open = True
        self.update()

    def GradientGenerator(self, start, end):
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


def account_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"

    app = WalletApp(user_id=g.logged_in_user["user_id"])

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
            title=Text('Settings', color="white"),
            bgcolor="black",
        ),
    )
    page.update()

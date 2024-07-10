import flet
import asyncio
from flet import *

from dbFunctions import Database
from settings import ColorList as cl
import clipboard


class App(UserControl):
    global HeightCount
    HeightCount = 25

    global ColorCount
    ColorCount = 0

    global CardCount
    CardCount = 0

    global DataDict
    DataDict = {}

    def WalletContainer(self):
        self.CardList = Column(
            alignment="start",
            spacing=25,
        )

        self.ImportButton = IconButton(
            icon=icons.DOWNLOAD,
            icon_color=colors.WHITE,
            icon_size=16,
            on_click=lambda e: asyncio.run(self.CheckDatabase()),
        )

        self.InsertButton = IconButton(
            icon=icons.ADD,
            icon_color=colors.WHITE,
            icon_size=16,
            on_click=lambda e: self.OpenEntryForm(),
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
                                        "Wallite",
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
                    gradient=self.GradientGenerator(
                        cl.WALLITE["from"], cl.WALLITE["to"]
                    ),
                ),
            ),
        )

        return self.WalletContainer

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
                TextButton("Insert", on_click=lambda e: self.CheckEntryForm()),
                TextButton("Cancel", on_click=lambda e: self.CheckEntryForm()),
            ],
            actions_alignment="center",
            on_dismiss=lambda e: self.CancelEntryForm(),
        )

        return self.EntryForm

    def CardGenerator(self, bank, number, cvv):
        global HeightCount
        global ColorCount
        global CardCount
        global DataDict

        self.img = Image(
            src="./icon.png",
            width=80,
            height=80,
            fit="contain",
        )

        self.bank = bank
        self.number = number
        self.cvv = cvv

        DataDict[CardCount] = {"number": f"{self.number}", "cvv": f"{self.cvv}"}

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
                                                data={DataDict[CardCount]["number"]},
                                                on_click=lambda e: self.GetValue(e),
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
                                                data=DataDict[CardCount]["cvv"],
                                                on_click=lambda e: self.GetValue(e),
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
                    cl.CARDCOLORS["from"][ColorCount],
                    cl.CARDCOLORS["to"][ColorCount],
                ),
            )
        )

        CardCount += 1
        ColorCount += 1
        HeightCount += 50

        self.CardList.controls.append(self.CardTest)
        self.CancelEntryForm()
        self.update()

    def GetValue(self, e):
        clipboard.copy(e.control.data)
        self.snack.open = True
        self.update()

    def GradientGenerator(self, start, end):
        self.ColorGradient = LinearGradient(
            begin=alignment.bottom_left,
            end=alignment.top_right,
            colors=[
                start,
                end,
            ],
        )

        return self.ColorGradient

    def CheckEntryForm(self):
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
            asyncio.run(self.InsertDataIntoDatabase())
            self.CardGenerator(
                self.BankName.value, self.CardNumber.value, self.CardCVV.value
            )

    def OpenEntryForm(self):
        self.dialog = self.EntryForm
        self.EntryForm.open = True
        self.update()

    def CancelEntryForm(self):
        self.BankName.value, self.CardNumber.value, self.CardCVV.value = (
            None,
            None,
            None,
        )

        self.CardNumber.error_text, self.BankName.error_text, self.CardCVV.value = (
            None,
            None,
            None,
        )

        self.EntryForm.open = False
        self.update()

    async def InsertDataIntoDatabase(self):
        db = await Database.ConnectDatabase()
        await Database.InsertDatabase(
            db, (self.BankName.value, self.CardNumber.value, self.CardCVV.value)
        )

        await db.commit()
        await db.close()

    async def CheckDatabase(self):
        db = await Database.ConnectDatabase()
        records = await Database.ReadDatabase(db)
        if records:
            for i, __ in enumerate(records):
                self.CardGenerator(records[i][0], records[i][1], records[i][2])
                self.ImportButton.disabled = True
                self.InsertButton.disabled = False
                self.update()
        else:
            self.InsertButton.disabled = False
            self.ImportButton.disabled = True
            self.update()

    def build(self):
        self.CardColumn = Column()
        self.snack = SnackBar(Text("Number copied!"))

        return Container(
            content=(
                Column(
                    alignment="center",
                    controls=[
                        self.EntryForm(),
                        self.WalletContainer(),
                    ],
                )
            ),
            width=900,
            height=800,
            margin=margin.all(-10),
            gradient=self.GradientGenerator(cl.BACKGROUND["from"], cl.BACKGROUND["to"]),
            alignment=alignment.center,
        )

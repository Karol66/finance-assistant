import flet
from flet import *

from app.controllers.account_controller import AccountController
from app.views.navigation_view import navigate_to, create_navigation_drawer
import app.globals as g


class Expanse(UserControl):
    def __init__(self, user_id):
        super().__init__()
        self.selected_link = None
        self.user_id = user_id
        self.account_controller = AccountController()
        self.selected_account_id = None

    def account_click(self, e, account_id):
        account = self.account_controller.get_account_by_id(account_id)
        g.selected_account = account
        navigate_to(e.page, "Manage account")

    def create_account_click(self, e):
        navigate_to(e.page, "Create account")

    def load_accounts(self):
        accounts = self.account_controller.get_user_accounts(self.user_id)

        for account in accounts:
            __ = Container(
                width=100,
                height=100,
                bgcolor="#132D46",
                border_radius=15,
                alignment=alignment.center,
                padding=padding.all(13),
                data=account["account_id"],
                on_click=lambda e, account_id=account["account_id"]: self.account_click(e, account_id),
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
                                bgcolor=account['account_color'],
                                border_radius=20,
                                alignment=alignment.center,
                                content=Icon(
                                    f"{account['account_icon']}",
                                    size=20,
                                    color="white",
                                ),
                            ),
                            Text(
                                f"{account['account_name']}",
                                size=16,
                                color="white54",
                            ),
                        ]
                    ),
                    Text(
                        f"{account['balance']}$",
                        size=16,
                        weight="bold",
                        color="white",
                    ),
                ],
            )
            self.grid_accounts.controls.append(__)

    def update_total_balance(self):
        accounts = self.account_controller.get_user_accounts(self.user_id)
        total_balance = 0.0

        for account in accounts:
            if account["include_in_total"] == 1:
                amount = float(account["balance"])
                total_balance += amount

        self.total_balance_amount.value = f"{total_balance:.2f}$"

    def build(self):
        self.main_col = Column(
            expand=True,
            alignment="center",
            horizontal_alignment="center",
        )

        self.grid_buttons = GridView(
            expand=False,
            max_extent=155,
            spacing=10,
            run_spacing=10,
            controls=[
                Container(
                    width=150,
                    height=150,
                    bgcolor="#191E29",
                    border_radius=15,
                    alignment=alignment.center,
                    content=Column(
                        alignment="center",
                        horizontal_alignment="center",
                        controls=[
                            Container(
                                width=60,
                                height=60,
                                bgcolor="#1EB980",
                                border_radius=18,
                                alignment=alignment.center,
                                content=Icon(
                                    icons.HISTORY,
                                    size=40,
                                    color="white",
                                ),
                            ),
                            Text(
                                "Transfer history",
                                size=16,
                                color="white",
                            ),
                        ],
                    ),
                    on_click=lambda e: print("History clicked")
                ),
                Container(
                    width=150,
                    height=150,
                    bgcolor="#191E29",
                    border_radius=15,
                    alignment=alignment.center,
                    content=Column(
                        alignment="center",
                        horizontal_alignment="center",
                        controls=[
                            Container(
                                width=60,
                                height=60,
                                bgcolor="#1EB980",
                                border_radius=18,
                                alignment=alignment.center,
                                content=Icon(
                                    icons.SYNC,
                                    size=40,
                                    color="white",
                                ),
                            ),
                            Text(
                                "New transfer",
                                size=16,
                                color="white",
                            ),
                        ],
                    ),
                    on_click=lambda e: print("New transfer clicked")
                ),
            ]
        )

        self.grid_accounts = GridView(
            expand=True,
            spacing=12,
            runs_count=1,
            max_extent=500,
            child_aspect_ratio=5.0,
        )

        self.total_balance_amount = Text(
            "0.00$",
            size=24,
            weight="bold",
            color="white"
        )

        self.update_total_balance()

        self.main_content_area = Container(
            width=350,
            height=640,
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
                                Text(
                                    "Sum:",
                                    size=16,
                                    color="white",
                                ),
                                self.total_balance_amount
                            ],
                        ),
                    ),
                    self.grid_buttons,
                    self.grid_accounts,
                ]
            )
        )

        self.load_accounts()

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
            on_click=self.create_account_click
        ))

        return self.main_col


def account_page(page: Page):
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
            title=Text('Account', color="white"),
            bgcolor="#132D46",
        ),
    )

    page.update()

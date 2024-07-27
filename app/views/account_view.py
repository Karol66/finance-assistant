import flet
from flet import *

class Expanse(UserControl):
    def __init__(self, user_id):
        super().__init__()
        self.selected_link = None
        self.user_id = user_id

    def load_accounts(self, account_type):
        accounts = [
            {"account_name": "Main", "balance": "10 zł", "account_color": "green", "account_icon": icons.ACCOUNT_BALANCE},
            {"account_name": "Savings", "balance": "50 zł", "account_color": "blue", "account_icon": icons.SAVINGS},
            {"account_name": "Expenses", "balance": "200 zł", "account_color": "red", "account_icon": icons.MONEY},
            {"account_name": "Expenses", "balance": "200 zł", "account_color": "red", "account_icon": icons.MONEY},
            {"account_name": "Expenses", "balance": "200 zł", "account_color": "red", "account_icon": icons.MONEY},
            {"account_name": "Expenses", "balance": "200 zł", "account_color": "red", "account_icon": icons.MONEY},
            {"account_name": "Expenses", "balance": "200 zł", "account_color": "red", "account_icon": icons.MONEY},
            {"account_name": "Expenses", "balance": "200 zł", "account_color": "red", "account_icon": icons.MONEY},
            {"account_name": "Expenses", "balance": "200 zł", "account_color": "red", "account_icon": icons.MONEY},
            {"account_name": "Expenses", "balance": "200 zł", "account_color": "red", "account_icon": icons.MONEY},
            {"account_name": "Expenses", "balance": "200 zł", "account_color": "red", "account_icon": icons.MONEY},
        ]

        for account in accounts:
            __ = Container(
                width=300,
                height=50,
                bgcolor="#132D46",
                border_radius=15,
                alignment=alignment.center,
                padding=padding.all(5),
                content=Row(
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
                                    color="white",
                                ),
                            ]
                        ),
                        Text(
                            f"{account['balance']}",
                            size=16,
                            weight="bold",
                            color="white",
                        ),
                    ],
                )
            )
            self.grid_accounts.controls.append(__)

    def build(self):
        self.main_col = Column(
            expand=True,
            alignment="center",
            horizontal_alignment="center",
        )

        self.grid_buttons = GridView(
            expand=False,
            max_extent=170,
            spacing=10,
            run_spacing=10,
            controls=[
                Container(
                    width=150,
                    height=150,
                    bgcolor="#4CAF50",
                    border_radius=15,
                    alignment=alignment.center,
                    content=Column(
                        alignment="center",
                        horizontal_alignment="center",
                        controls=[
                            Icon(
                                icons.HISTORY,
                                size=40,
                                color="white",
                            ),
                            Text(
                                "Historia przelewów",
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
                    bgcolor="#4CAF50",
                    border_radius=15,
                    alignment=alignment.center,
                    content=Column(
                        alignment="center",
                        horizontal_alignment="center",
                        controls=[
                            Icon(
                                icons.ADD,
                                size=40,
                                color="white",
                            ),
                            Text(
                                "Nowy przelew",
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

        self.main_content_area = Container(
            width=350,
            height=700,
            bgcolor="#191E29",
            padding=padding.only(top=10, left=10, right=10),
            content=Column(
                spacing=20,
                expand=True,
                alignment="start",
                horizontal_alignment="center",
                controls=[
                    Text(
                        "Suma: 10 zł",
                        size=20,
                        color="white",
                        weight="bold",
                    ),
                    self.grid_buttons,
                    self.grid_accounts,
                ]
            )
        )

        self.load_accounts("Accounts")

        self.main_col.controls.append(self.main_content_area)

        return self.main_col


def account_page(page: Page):
    page.title = "Finance Assistant"
    page.horizontal_alignment = CrossAxisAlignment.CENTER
    page.auto_scroll = False
    page.scroll = ScrollMode.AUTO
    page.bgcolor = "#191E29"

    app = Expanse(user_id="example_user_id")

    page.add(app)

    fab_container = Container(
        alignment=alignment.bottom_center,
        margin=margin.only(bottom=20),
        content=FloatingActionButton(
            icon=icons.ADD,
            bgcolor=colors.LIME_300,
            on_click=lambda e: print("Create account clicked")
        )
    )

    page.overlay.append(fab_container)
    page.update()


if __name__ == "__main__":
    flet.app(target=account_page)

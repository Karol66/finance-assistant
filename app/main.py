import flet
from flet import *


def main(page: Page):
    page.horizontal_alignment = CrossAxisAlignment.CENTER

    def handle_dismissal(e):
        page.add(Text("Drawer dismissed"))

    drawer = NavigationDrawer(
        on_dismiss=handle_dismissal,
        bgcolor="black",
        controls=[
            Container(
                height=80,
                padding=padding.all(10),
                content=Row(
                    controls=[
                        Container(
                            width=52,
                            height=52,
                            bgcolor="bluegrey900",
                            alignment=alignment.center,
                            border_radius=8,
                            content=Text(
                                value="JK",
                                size=24,
                                weight="bold",
                                color="white"
                            ),
                        ),
                        Column(
                            spacing=2,
                            alignment=MainAxisAlignment.CENTER,
                            controls=[
                                Text(
                                    value="Jan Kowalski",
                                    size=14,
                                    weight="bold",
                                    color="white"
                                ),
                                Text(
                                    value="Software Engineer",
                                    size=12,
                                    weight="w400",
                                    color="white54"
                                ),
                            ]
                        )
                    ]
                )
            ),
            Divider(height=5, color="white24"),
            NavigationDrawerDestination(
                label="Dashboard",
                icon=icons.DASHBOARD_OUTLINED,
                selected_icon_content=Icon(icons.DASHBOARD, color="black"),
            ),
            NavigationDrawerDestination(
                label="Wallet",
                icon=icons.WALLET_ROUNDED,
                selected_icon_content=Icon(icons.WALLET_ROUNDED, color="black"),
            ),
            NavigationDrawerDestination(
                label="Analytics",
                icon=icons.BAR_CHART,
                selected_icon_content=Icon(icons.BAR_CHART, color="black"),
            ),
            NavigationDrawerDestination(
                label="Categories",
                icon=icons.GRID_VIEW_ROUNDED,
                selected_icon_content=Icon(icons.GRID_VIEW_ROUNDED, color="black"),
            ),
            NavigationDrawerDestination(
                label="Regular payments",
                icon=icons.ATTACH_MONEY,
                selected_icon_content=Icon(icons.ATTACH_MONEY, color="black"),
            ),
            NavigationDrawerDestination(
                label="Notifications",
                icon=icons.NOTIFICATIONS,
                selected_icon_content=Icon(icons.NOTIFICATIONS, color="black"),
            ),
            NavigationDrawerDestination(
                label="Settings",
                icon=icons.SETTINGS,
                selected_icon_content=Icon(icons.SETTINGS, color="black"),
            ),
            Divider(height=5, color="white24"),
            NavigationDrawerDestination(
                label="Logout",
                icon=icons.LOGOUT_ROUNDED,
                selected_icon_content=Icon(icons.LOGOUT_ROUNDED, color="black"),
            ),
        ],
    )

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
            title=Text('Home',
                       color="white"),
            bgcolor="black",
        )
    )


app(main)

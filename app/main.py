import flet as ft

def main(page: ft.Page):
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    def handle_dismissal(e):
        page.add(ft.Text("Drawer dismissed"))

    def handle_change(e):
        page.add(ft.Text(f"Selected Index changed: {e.selected_index}"))

    drawer = ft.NavigationDrawer(
        on_dismiss=handle_dismissal,
        bgcolor="black",
        controls=[
            ft.Container(
                height=80,
                padding=ft.padding.all(10),
                content=ft.Row(
                    controls=[
                        ft.Container(
                            width=52,
                            height=52,
                            bgcolor="bluegrey900",
                            alignment=ft.alignment.center,
                            border_radius=8,
                            content=ft.Text(
                                value="JK",
                                size=24,
                                weight="bold",
                                color="white"
                            ),
                        ),
                        ft.Column(
                            spacing=2,
                            alignment=ft.MainAxisAlignment.CENTER,
                            controls=[
                                ft.Text(
                                    value="Jan Kowalski",
                                    size=14,
                                    weight="bold",
                                    color="white"
                                ),
                                ft.Text(
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
            ft.Divider(height=5, color="white24"),
            ft.NavigationDrawerDestination(
                label="Search",
                icon=ft.icons.SEARCH,
                selected_icon_content=ft.Icon(ft.icons.SEARCH, color="white"),
            ),
            ft.NavigationDrawerDestination(
                label="Dashboard",
                icon=ft.icons.DASHBOARD_OUTLINED,
                selected_icon_content=ft.Icon(ft.icons.DASHBOARD, color="white"),
            ),
            ft.NavigationDrawerDestination(
                label="Revenue",
                icon=ft.icons.BAR_CHART,
                selected_icon_content=ft.Icon(ft.icons.BAR_CHART, color="white"),
            ),
            ft.NavigationDrawerDestination(
                label="Notifications",
                icon=ft.icons.NOTIFICATIONS,
                selected_icon_content=ft.Icon(ft.icons.NOTIFICATIONS, color="white"),
            ),
            ft.NavigationDrawerDestination(
                label="Analytics",
                icon=ft.icons.PIE_CHART_ROUNDED,
                selected_icon_content=ft.Icon(ft.icons.PIE_CHART_ROUNDED, color="white"),
            ),
            ft.NavigationDrawerDestination(
                label="Likes",
                icon=ft.icons.FAVORITE_ROUNDED,
                selected_icon_content=ft.Icon(ft.icons.FAVORITE_ROUNDED, color="white"),
            ),
            ft.NavigationDrawerDestination(
                label="Wallet",
                icon=ft.icons.WALLET_ROUNDED,
                selected_icon_content=ft.Icon(ft.icons.WALLET_ROUNDED, color="white"),
            ),
            ft.Divider(height=5, color="white24"),
            ft.NavigationDrawerDestination(
                label="Logout",
                icon=ft.icons.LOGOUT_ROUNDED,
                selected_icon_content=ft.Icon(ft.icons.LOGOUT_ROUNDED, color="white"),
            ),
        ],
    )

    page.add(
        ft.Row(
            alignment=ft.MainAxisAlignment.CENTER,
            controls=[
                ft.ElevatedButton("Show drawer", on_click=lambda e: page.open(drawer))
            ],
        )
    )

ft.app(main)

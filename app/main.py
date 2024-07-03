import flet
from flet import *
from app.login import login_view
from app.registration import registration_view

def main(page: Page):
    page.horizontal_alignment = CrossAxisAlignment.CENTER

    def handle_dismissal(e):
        page.add(Text("Drawer dismissed"))

    def navigate_to(destination):
        print(f"Navigating to: {destination}")  # Debugging line
        page.controls.clear()
        if destination == "Login":
            page.add(login_view(navigate_to_registration))
        elif destination == "Register":
            page.add(registration_view(navigate_to_login))
        elif destination == "Dashboard":
            page.add(Text("Dashboard Page"))
        elif destination == "Wallet":
            page.add(Text("Wallet Page"))
        elif destination == "Analytics":
            page.add(Text("Analytics Page"))
        elif destination == "Categories":
            page.add(Text("Categories Page"))
        elif destination == "Regular payments":
            page.add(Text("Regular payments Page"))
        elif destination == "Notifications":
            page.add(Text("Notifications Page"))
        elif destination == "Settings":
            page.add(Text("Settings Page"))
        elif destination == "Logout":
            page.add(Text("Logout Page"))
        else:
            page.add(Text(f"Unknown destination: {destination}"))
        page.update()

    def navigate_to_registration(e):
        navigate_to("Register")

    def navigate_to_login(e):
        navigate_to("Login")

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
                label="Login",
                icon=icons.LOGIN,
                selected_icon_content=Icon(icons.LOGIN, color="black"),
            ),
            NavigationDrawerDestination(
                label="Register",
                icon=icons.APP_REGISTRATION,
                selected_icon_content=Icon(icons.APP_REGISTRATION, color="black"),
            ),
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

    def on_drawer_change(e):
        selected_index = (e.control.selected_index + 2)
        selected_control = e.control.controls[selected_index]
        if isinstance(selected_control, NavigationDrawerDestination):
            selected_label = selected_control.label
            navigate_to(selected_label)

    drawer.on_change = on_drawer_change

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
            title=Text('Home', color="white"),
            bgcolor="black",
        )
    )

    page.update()


flet.app(target=main)

from flet import *


def navigate_to(page, destination):
    print(f"Navigating to: {destination}")  # Debugging line
    page.controls.clear()
    if destination == "Login":
        from login import login_page
        login_page(page)
    elif destination == "Register":
        from registration import registration_page
        registration_page(page)
    elif destination == "Dashboard":
        from main import main as dashboard_main
        dashboard_main(page)
    elif destination == "Wallet":
        from wallet import wallet_page
        wallet_page(page)
    elif destination == "Statistic":
        page.add(Text("Statistic Page"))
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


def create_navigation_drawer(page):
    drawer = NavigationDrawer(
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
                label="Statistic",
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
            navigate_to(page, selected_label)

    drawer.on_change = on_drawer_change
    return drawer

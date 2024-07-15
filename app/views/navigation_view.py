from flet import *
import app.globals as g

# Globalna zmienna drawer
drawer = None

def navigate_to(page, destination):
    global drawer  # Odwołanie do globalnej zmiennej drawer
    print(f"Navigating to: {destination}")
    page.controls.clear()
    if destination == "Login":
        from app.views.login_view import login_page
        login_page(page)
    elif destination == "Register":
        from app.views.registration_view import registration_page
        registration_page(page)
    elif destination == "Dashboard":
        from app.views.dashboard import dashboard_page
        dashboard_page(page)
    elif destination == "Account":
        from app.views.account_view import account_page
        account_page(page)
    elif destination == "Statistic":
        from app.views.statistic import statistic_page
        statistic_page(page)
    elif destination == "Categories":
        from app.views.categories import categories_page
        categories_page(page)
    elif destination == "Regular payments":
        from app.views.payments import payments_page
        payments_page(page)
    elif destination == "Notifications":
        from app.views.notifications import notyfications_page
        notyfications_page(page)
    elif destination == "Settings":
        from app.views.settings import settings_page
        settings_page(page)
    elif destination == "Logout":
        g.logged_in_user = None
        drawer.visible = False  # Ukryj pasek nawigacyjny
        from app.views.login_view import login_page
        login_page(page)
    else:
        page.add(Text(f"Unknown destination: {destination}"))
    page.update()

def create_navigation_drawer(page):
    global drawer  # Odwołanie do globalnej zmiennej drawer
    if g.logged_in_user is None:
        user_initials = Icon(icons.PERSON, size=24, color="white")
        username_text = "Register"
        user_role = ""
    else:
        user_initials = Text(
            value=g.logged_in_user["username"][0].upper() + g.logged_in_user["username"][1].upper(),
            size=24,
            weight="bold",
            color="white"
        )
        username_text = g.logged_in_user["username"]
        user_role = g.logged_in_user["email"]

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
                            content=user_initials,
                        ),
                        Column(
                            spacing=2,
                            alignment=MainAxisAlignment.CENTER,
                            controls=[
                                Text(
                                    value=username_text,
                                    size=14,
                                    weight="bold",
                                    color="white"
                                ),
                                Text(
                                    value=user_role,
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
                label="Account",
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
        # Pobieramy aktualnie zaznaczony indeks
        selected_index = e.control.selected_index

        # Filtrujemy tylko elementy, które są instancjami NavigationDrawerDestination
        destinations = []
        for ctrl in e.control.controls:
            if isinstance(ctrl, NavigationDrawerDestination):
                destinations.append(ctrl)

        # Jeżeli selected_index przekracza liczbę destynacji, ustawiamy go na ostatni indeks
        if selected_index >= len(destinations):
            selected_index = len(destinations) - 1

        # Pobieramy wybraną destynację
        selected_control = destinations[selected_index]
        selected_label = selected_control.label
        navigate_to(page, selected_label)

    drawer.on_change = on_drawer_change
    return drawer

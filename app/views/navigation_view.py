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

    drawer.selected_index = get_selected_index(destination)
    page.update()


def get_selected_index(destination):
    labels = ["Dashboard", "Account", "Statistic", "Categories", "Regular payments", "Notifications", "Settings",
              "Logout"]
    if destination in labels:
        return labels.index(destination)
    return 0


def create_navigation_drawer(page):
    global drawer  # Odwołanie do globalnej zmiennej drawer

    def login_click(e):
        navigate_to(page, "Login")

    user_icon = Icon(icons.PERSON_ROUNDED, size=30, color="white")

    if g.logged_in_user is None:
        username_text = Container(
            content=Text(
                value="Login in",
                size=20,
                color="white",
                text_align=TextAlign.CENTER
            ),
            on_click=login_click
        )

        username_container = Row(
            alignment=alignment.center,
            controls=[
                Container(
                    width=52,
                    height=52,
                    bgcolor="bluegrey900",
                    alignment=alignment.center,
                    border_radius=8,
                    content=user_icon,
                ),
                username_text
            ]
        )
    else:
        username_text = Text(
            value=g.logged_in_user["username"],
            size=14,
            weight="bold",
            color="white"
        )
        user_role = g.logged_in_user["email"]
        username_container = Row(
            alignment=alignment.center,
            controls=[
                Container(
                    width=52,
                    height=52,
                    bgcolor="bluegrey900",
                    alignment=alignment.center,
                    border_radius=8,
                    content=user_icon,
                ),
                Column(
                    spacing=2,
                    alignment=MainAxisAlignment.CENTER,
                    controls=[
                        username_text,
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

    drawer = NavigationDrawer(
        bgcolor="black",
        controls=[
            Container(
                height=80,
                padding=padding.all(10),
                content=Row(
                    controls=[
                        username_container
                    ]
                )
            ),
            Divider(height=5, color="white24"),
            NavigationDrawerDestination(
                label="Dashboard",
                icon=icons.DASHBOARD_OUTLINED,
            ),
            NavigationDrawerDestination(
                label="Account",
                icon=icons.WALLET_ROUNDED,
            ),
            NavigationDrawerDestination(
                label="Statistic",
                icon=icons.BAR_CHART,
            ),
            NavigationDrawerDestination(
                label="Categories",
                icon=icons.GRID_VIEW_ROUNDED,
            ),
            NavigationDrawerDestination(
                label="Regular payments",
                icon=icons.ATTACH_MONEY,
            ),
            NavigationDrawerDestination(
                label="Notifications",
                icon=icons.NOTIFICATIONS,
            ),
            NavigationDrawerDestination(
                label="Settings",
                icon=icons.SETTINGS,
            ),
            Divider(height=5, color="white24"),
            NavigationDrawerDestination(
                label="Logout",
                icon=icons.LOGOUT_ROUNDED,
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

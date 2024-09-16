from flet import *
import app.globals as g

# Globalna zmienna drawer
drawer = None

def navigate_to(page, destination):
    global drawer  # Odwołanie do globalnej zmiennej drawer
    page.controls.clear()
    if destination == "Login":
        from app.views.login_view import login_page
        login_page(page)
    elif destination == "Register":
        from app.views.registration_view import registration_page
        registration_page(page)
    elif destination == "Dashboard":
        from app.views.dashboard_view import dashboard_page
        dashboard_page(page)
    elif destination == "Account":
        from app.views.account_view import account_page
        account_page(page)
    elif destination == "Create account":
        from app.views.account_create_view import create_account_page
        create_account_page(page)
    elif destination == "Manage account":
        from app.views.account_management_view import manage_account_page
        manage_account_page(page)
    elif destination == "Statistic":
        from app.views.statistic import statistic_page
        statistic_page(page)
    elif destination == "Categories":
        from app.views.category_view import categories_page
        categories_page(page)
    elif destination == "Create category":
        from app.views.category_create_view import create_category_page
        create_category_page(page)
    elif destination == "Manage category":
        from app.views.category_management_view import manage_category_page
        manage_category_page(page)
    elif destination == "Transaction":
        from app.views.transaction_view import transaction_page
        transaction_page(page)
    elif destination == "Create transaction":
        from app.views.transaction_create_view import create_transaction_page
        create_transaction_page(page)
    elif destination == "Manage transaction":
        from app.views.transaction_management_view import manage_transaction_page
        manage_transaction_page(page)
    elif destination == "Cards":
        from app.views.card_view import card_page
        card_page(page)
    elif destination == "Create card":
        from app.views.card_create_view import create_card_page
        create_card_page(page)
    elif destination == "Manage card":
        from app.views.card_management_view import manage_card_page
        manage_card_page(page)
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


class CustomNavigationDrawerDestination(UserControl):
    def __init__(self, icon, label, destination, page, on_click=None):
        super().__init__()
        self.icon = icon
        self.label = label
        self.destination = destination
        self.page = page
        self.on_click = on_click

    def build(self):
        return Container(
            content=Row(
                controls=[
                    Icon(name=self.icon, color="white", size=25),  # Zwiększenie rozmiaru ikony
                    Text(value=self.label, color="white", weight="bold", size=15)  # Zwiększenie rozmiaru tekstu
                ],
                spacing=15,  # Zwiększenie odstępu między ikoną a tekstem
                alignment="start",  # Wyrównanie do lewej
                vertical_alignment="center"
            ),
            padding=padding.symmetric(vertical=20, horizontal=20),  # Zwiększenie paddingu dla większej wysokości przycisków
            on_click=lambda e: navigate_to(self.page, self.destination) if self.on_click is None else self.on_click(e),
            border_radius=8,
            ink=True,
        )

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
                weight="bold",
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
                    bgcolor="#191E29",
                    alignment=alignment.center,
                    border_radius=8,
                    content=user_icon,
                    margin=margin.only(right=10)
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
                    bgcolor="#191E29",
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
        bgcolor="#132D46",
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
            Divider(height=10, color="white"),
            CustomNavigationDrawerDestination(
                icon=icons.DASHBOARD_OUTLINED,
                label="Dashboard",
                destination="Dashboard",
                page=page
            ),
            CustomNavigationDrawerDestination(
                icon=icons.WALLET_ROUNDED,
                label="Account",
                destination="Account",
                page=page
            ),
            CustomNavigationDrawerDestination(
                icon=icons.BAR_CHART,
                label="Statistic",
                destination="Statistic",
                page=page
            ),
            CustomNavigationDrawerDestination(
                icon=icons.GRID_VIEW_ROUNDED,
                label="Categories",
                destination="Categories",
                page=page
            ),
            CustomNavigationDrawerDestination(
                icon=icons.ATTACH_MONEY,
                label="Regular payments",
                destination="Regular payments",
                page=page
            ),
            CustomNavigationDrawerDestination(
                icon=icons.NOTIFICATIONS,
                label="Notifications",
                destination="Notifications",
                page=page
            ),
            CustomNavigationDrawerDestination(
                icon=icons.SETTINGS,
                label="Settings",
                destination="Settings",
                page=page
            ),
            CustomNavigationDrawerDestination(
                icon=icons.CARD_GIFTCARD,
                label="Cards",
                destination="Cards",
                page=page
            ),
            Divider(height=10, color="white"),
            CustomNavigationDrawerDestination(
                icon=icons.LOGOUT_ROUNDED,
                label="Logout",
                destination="Logout",
                page=page
            ),
        ],
    )

    def on_drawer_change(e):
        # Pobieramy aktualnie zaznaczony indeks
        selected_index = e.control.selected_index

        # Filtrujemy tylko elementy, które są instancjami NavigationDrawerDestination
        destinations = []
        for ctrl in e.control.controls:
            if isinstance(ctrl, CustomNavigationDrawerDestination):
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

import datetime
import flet
from flet import *
from app.views.navigation_view import create_navigation_drawer
from app.controllers.category_controller import CategoryController
import app.globals as g

class Expanse(UserControl):

    def __init__(self, user_id, category_id):
        super().__init__()
        self.selected_link = None
        self.selected_color_container = None
        self.selected_color = None
        self.last_selected_icon = None
        self.last_selected_icon_original_color = None
        self.selected_icon = None
        self.category_controller = CategoryController()
        self.user_id = user_id
        self.category_id = category_id

        # Pobierz dane kategorii ze zmiennych globalnych
        self.category_data = g.selected_category  # Pobranie danych kategorii ze zmiennej globalnej
        self.category_name = self.category_data.get("category_name", "")
        self.category_type = self.category_data.get("category_type", "Expenses")
        self.category_color = self.category_data.get("category_color", colors.GREY)
        self.category_icon = self.category_data.get("category_icon", icons.MORE_HORIZ)
        self.planned_expenses = self.category_data.get("planned_expenses", "")

        # Referencja do ikony załadowanej z bazy danych
        self.loaded_icon_container = None  # Śledzenie załadowanej ikony

    def InputTextField(self, text: str, hide: bool, ref, width="100%", value=""):
        return Container(
            alignment=alignment.center,
            content=TextField(
                height=58,
                width=width,
                bgcolor="#f0f3f6",
                text_size=14,
                color="black",
                border_color="transparent",
                hint_text=text,
                filled=True,
                cursor_color="black",
                hint_style=TextStyle(
                    size=13,
                    color="black",
                ),
                password=hide,
                ref=ref,
                value=value,  # Ustaw wartość początkową
            ),
        )

    def on_color_click(self, e):
        if self.selected_color_container == e.control:
            # Odznacz aktualnie wybrany kontener
            self.selected_color_container.content.controls = []
            self.selected_color_container.update()
            self.selected_color_container = None
            self.selected_color = None
        else:
            if self.selected_color_container:
                # Usuń ikonę z wcześniej wybranego kontenera
                self.selected_color_container.content.controls = []
                self.selected_color_container.update()

            # Dodaj ikonę do nowo wybranego kontenera
            self.selected_color_container = e.control
            self.selected_color = e.control.bgcolor  # Zapisz wybrany kolor
            if self.selected_color_container.content:
                self.selected_color_container.content.controls.append(
                    Container(
                        alignment=alignment.center,
                        content=Icon(
                            icons.CHECK,
                            size=16,
                            color="white",
                        ),
                    )
                )
                self.selected_color_container.update()

            # Zastosuj logikę zmiany koloru tutaj
            if self.last_selected_icon:
                self.last_selected_icon.bgcolor = self.selected_color
                self.last_selected_icon.update()
            else:
                # Zmień kolor załadowanej ikony, jeśli nie wybrano żadnej ikony
                if self.loaded_icon_container:
                    self.loaded_icon_container.bgcolor = self.selected_color
                    self.loaded_icon_container.update()

    def on_icon_click(self, e):
        # Przywróć kolor tła załadowanej ikony z bazy danych
        if self.loaded_icon_container and self.loaded_icon_container != e.control:
            self.loaded_icon_container.bgcolor = "#132D46"
            self.loaded_icon_container.border = None
            self.loaded_icon_container.update()

        if self.last_selected_icon:
            # Przywróć oryginalny kolor tła i usuń obramowanie z ostatnio wybranego kontenera
            self.last_selected_icon.bgcolor = "#132D46"
            self.last_selected_icon.border = None
            self.last_selected_icon.update()

        # Zapisz referencję do nowo wybranego kontenera i jego oryginalnego koloru tła
        self.last_selected_icon = e.control
        self.last_selected_icon_original_color = e.control.bgcolor

        # Zmień kolor tła nowo wybranego kontenera, jeśli wybrano kolor
        if self.selected_color:
            e.control.bgcolor = self.selected_color

        # Dodaj obramowanie do nowo wybranego kontenera
        e.control.border = border.all(4, colors.WHITE)
        e.control.update()

        # Zapisz wybraną ikonę
        self.selected_icon = e.control.data

    def update_category(self, e):
        category_name = self.category_name_input.current.value
        planned_expenses = self.planned_expenses_input.current.value
        category_type = self.category_type_radio_group.current.value
        category_color = self.selected_color
        # Użyj wybranej ikony, jeśli istnieje, w przeciwnym razie użyj ikony z bazy danych
        category_icon = self.selected_icon if self.selected_icon else self.category_icon

        self.category_controller.update_category(self.category_id, self.user_id, category_name, category_type, planned_expenses,
                                                 category_color, category_icon)
        print("Kategoria została zaktualizowana pomyślnie")

    def delete_category(self, e):
        self.category_controller.delete_category(self.category_id, self.user_id)
        print("Metoda usuwania kategorii została wywołana.")

    def build(self):
        self.category_name_input = Ref[TextField]()
        self.planned_expenses_input = Ref[TextField]()
        self.category_type_radio_group = Ref[RadioGroup]()

        self.main_col = Column(
            expand=True,
            alignment="center",
            horizontal_alignment="center",
        )

        self.grid_transfers = GridView(
            expand=True,
            max_extent=100,
            spacing=10,
            run_spacing=10,
        )

        self.main_content_area = Container(
            width=400,
            height=800,
            bgcolor="#191E29",
            padding=padding.only(top=10, left=10, right=10, bottom=10),
            content=Column(
                spacing=20,
                controls=[
                    Container(
                        width=400,
                        content=Column(
                            spacing=10,
                            controls=[
                                self.InputTextField(
                                    "Nazwa kategorii",
                                    False,
                                    self.category_name_input,
                                    width="100%",
                                    value=self.category_name
                                ),
                                RadioGroup(
                                    ref=self.category_type_radio_group,
                                    value=self.category_type,  # Ustaw wartość początkową
                                    content=Row(
                                        controls=[
                                            Radio(value="Expenses", label="Wydatki",
                                                  label_style=TextStyle(color=colors.WHITE)),
                                            Radio(value="Income", label="Przychody",
                                                  label_style=TextStyle(color=colors.WHITE)),
                                        ],
                                        alignment="center",
                                        spacing=80,
                                    ),
                                ),
                                self.InputTextField(
                                    "Planowane wydatki",
                                    False,
                                    self.planned_expenses_input,
                                    width="100%",
                                    value=self.planned_expenses
                                ),
                            ]
                        )

                    ),

                    Row(
                        alignment="center",
                        wrap=True,
                        controls=[
                            Container(width=30, height=30, bgcolor=colors.RED, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.GREEN, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.BLUE, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.YELLOW, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.ORANGE, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.PURPLE, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.BROWN, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(width=30, height=30, bgcolor=colors.PINK, border_radius=15, margin=1,
                                      on_click=self.on_color_click, content=Column(alignment="center", controls=[])),
                            Container(
                                width=30,
                                height=30,
                                bgcolor=colors.GREY,
                                border_radius=15,
                                margin=1,
                                alignment=alignment.center,
                                content=Icon(
                                    icons.ADD,
                                    size=16,
                                    color="white",
                                ),
                            ),
                        ]
                    ),
                    self.grid_transfers,

                    Container(
                        alignment=alignment.center,
                        content=ElevatedButton(
                            content=Text(
                                "Aktualizuj",
                                size=14,
                                weight="bold",
                            ),
                            bgcolor="#01C38D",
                            color="white",
                            style=ButtonStyle(
                                shape={
                                    "": RoundedRectangleBorder(radius=8)
                                },
                            ),
                            height=58,
                            width=300,
                            on_click=self.update_category
                        )
                    ),
                    Container(
                        alignment=alignment.center,
                        content=ElevatedButton(
                            content=Text(
                                "Usuń",
                                size=14,
                                weight="bold",
                            ),
                            bgcolor="#01C38D",
                            color="white",
                            style=ButtonStyle(
                                shape={
                                    "": RoundedRectangleBorder(radius=8)
                                },
                            ),
                            height=58,
                            width=300,
                            on_click=self.delete_category
                        )
                    )
                ]
            )
        )

        icon_list = [
            [icons.DIRECTIONS_CAR],
            [icons.PHONE],
            [icons.BOLT],
            [icons.FLIGHT],
            [icons.NETWORK_WIFI],
            [icons.HOME],
            [icons.FOOD_BANK],
            [icons.SCHOOL],
            [icons.HEALTH_AND_SAFETY],
            [icons.THEATER_COMEDY],
            [icons.SHOPPING_BAG],
            [icons.SPORTS],
            [icons.WORK],
            [icons.FOREST],
            [icons.TRAVEL_EXPLORE],
        ]

        for i in icon_list:
            # Sprawdź, czy ta ikona jest wybrana
            icon_bgcolor = self.category_color if i[0] == self.category_icon else "#132D46"
            icon_border = border.all(4, colors.WHITE) if i[0] == self.category_icon else None  # Dodaj obramowanie jeśli to ikona z bazy danych

            item_container = Container(
                width=100,
                height=100,
                bgcolor=icon_bgcolor,
                border_radius=15,
                alignment=alignment.center,
                on_click=self.on_icon_click,
                data=i[0],  # Dodaj nazwę ikony jako dane do kontenera
                border=icon_border,  # Ustaw obramowanie dla załadowanej ikony
                content=Column(
                    alignment="center",
                    horizontal_alignment="center",
                    controls=[
                        Icon(
                            f"{i[0]}",
                            size=40,
                            color="white",
                        ),
                    ]
                )
            )

            # Przechowaj referencję do ikony załadowanej z bazy danych
            if i[0] == self.category_icon:
                self.loaded_icon_container = item_container

            self.grid_transfers.controls.append(item_container)

        more_button = Container(
            width=100,
            height=100,
            bgcolor="#494E59",
            border_radius=15,
            alignment=alignment.center,
            content=Column(
                alignment="center",
                horizontal_alignment="center",
                controls=[
                    Icon(
                        icons.MORE_HORIZ,
                        size=30,
                        color="white",
                    ),
                ]
            )
        )
        self.grid_transfers.controls.append(more_button)
        self.main_col.controls.append(self.main_content_area)

        return self.main_col


def manage_category_page(page: Page):
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"

    app = Expanse(user_id=g.logged_in_user["user_id"], category_id=g.selected_category["category_id"])

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
            title=Text('Zarządzaj kategorią', color="white"),
            bgcolor="#132D46",
        ),
    )
    page.update()

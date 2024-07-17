import flet as ft
from flet import *
from app.controllers.user_controller import UserController
from app.views.navigation_view import navigate_to, create_navigation_drawer


class UserWidget(UserControl):
    def __init__(self, title: str, sub_title: str, btn_name: str, link: str, navigate_to_login):
        self.title = title
        self.sub_title = sub_title
        self.btn_name = btn_name
        self.link = link
        self.navigate_to_login = navigate_to_login
        self.user_controller = UserController()  # Inicjalizacja kontrolera użytkownika
        super().__init__()

    def InputTextField(self, text: str, hide: bool, ref):
        return Container(
            alignment=alignment.center,
            content=TextField(
                height=58,
                width=300,
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
                ref=ref  # Dodanie referencji do pola tekstowego
            ),
        )

    def SignInOption(self, path: str, name: str):
        return Container(
            content=ElevatedButton(
                content=Row(
                    alignment="center",
                    spacing=4,
                    controls=[
                        Image(
                            src=path,
                            width=35,
                            height=35,
                        ),
                        Text(
                            name,
                            color="black",
                            size=12,
                            weight="bold",
                        )
                    ],
                ),
                style=ButtonStyle(
                    shape={
                        "": RoundedRectangleBorder(radius=8),
                    },
                    bgcolor={
                        "": "#f0f3f6",
                    }
                ),
            ),
        )

    def show_dialog(self, page, title, content, color, on_close):
        dlg_modal = AlertDialog(
            modal=True,
            title=Text(title, color=color),
            content=Text(content),
            actions=[
                TextButton("OK", on_click=lambda e: [page.close(dlg_modal), on_close(e)]),
            ],
            actions_alignment=MainAxisAlignment.END,
        )
        page.open(dlg_modal)

    def register(self, e):
        email = self.email_input.current.value
        username = self.username_input.current.value
        password = self.password_input.current.value
        confirm_password = self.confirm_password_input.current.value

        # Wywołanie metody rejestracji w kontrolerze
        result = self.user_controller.register_user(email, username, password, confirm_password)

        # Obsługa wyniku rejestracji
        if result["status"] == "error":
            self.show_dialog(e.page, "Error", result["message"], colors.RED, lambda _: None)
        else:
            self.email_input.current.value = ""
            self.password_input.current.value = ""
            self.confirm_password_input.current.value = ""
            self.show_dialog(e.page, "Success", result["message"], colors.GREEN,
                             lambda e: navigate_to(e.page, "Login"))

        e.page.update()

    def build(self):
        # Definiowanie referencji do pól tekstowych
        self.email_input = Ref[TextField]()
        self.username_input = Ref[TextField]()
        self.password_input = Ref[TextField]()
        self.confirm_password_input = Ref[TextField]()

        self._title = Container(
            alignment=alignment.center,
            content=Text(
                self.title,
                size=24,
                text_align="center",
                weight="bold",
                color="black",
            )
        )

        self._sub_title = Container(
            alignment=alignment.center,
            content=Text(
                self.sub_title,
                size=18,
                text_align="center",
                color="black",
            )
        )

        self._link = Container(
            alignment=alignment.center,
            content=Row(
                alignment="center",
                controls=[
                    Text("Already have an account?", size=12, color="black"),
                    Container(
                        content=Text(
                            self.link,
                            size=12,
                            color="green",
                            weight="bold",
                        ),
                        on_click=self.navigate_to_login,
                    )
                ]
            )
        )

        self._sign_up = Container(
            alignment=alignment.center,
            content=ElevatedButton(
                on_click=self.register,  # Wywołanie funkcji rejestracji
                content=Text(
                    self.btn_name,
                    size=14,
                    weight="bold",
                ),
                bgcolor="black",
                color="white",
                style=ButtonStyle(
                    shape={
                        "": RoundedRectangleBorder(radius=8)
                    },
                ),
                height=58,
                width=300,
            )
        )

        class DividerWithText(Container):
            def __init__(self, text):
                super().__init__(
                    content=Row(
                        controls=[
                            Container(width=120, height=1, bgcolor="black"),
                            Text(text, color="black", weight='w400'),
                            Container(width=120, height=1, bgcolor="black"),
                        ],
                        alignment='center',
                        spacing=10,
                    )
                )

        return Column(
            horizontal_alignment="center",
            controls=[
                self._title,
                self._sub_title,
                Container(padding=3),
                Column(
                    spacing=10,
                    controls=[
                        self.InputTextField("Email", False, self.email_input),  # Pole tekstowe email z referencją
                        self.InputTextField("Username", False, self.username_input),
                        self.InputTextField("Password", True, self.password_input),  # Pole tekstowe hasło z referencją
                        self.InputTextField("Confirm Password", True, self.confirm_password_input),
                        # Pole tekstowe potwierdzenia hasła z referencją
                    ],
                ),
                Container(padding=2),
                self._sign_up,
                Container(padding=2),
                Column(
                    horizontal_alignment="center",
                    controls=[
                        DividerWithText("or"),
                        self.SignInOption("./app/assets/icon.png", "Facebook"),
                        self.SignInOption("./app/assets/icon.png", "Google"),
                    ],
                ),
                Container(padding=2),
                self._link,
            ],
        )


def registration_page(page: Page):
    def _main_column():
        return Container(
            width=320,
            height=700,
            bgcolor="#ffffff",
            padding=10,
            border_radius=35,
            content=Column(
                spacing=25,
                horizontal_alignment="center",
            )
        )

    user_widget = UserWidget(
        "Registration",
        "Register your data below",
        "Register",
        "Log In",
        lambda e: navigate_to(page, "Login")
    )

    reg_main = _main_column()
    reg_main.content.controls.append(Container(padding=1))
    reg_main.content.controls.append(user_widget)

    drawer = create_navigation_drawer(page)
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
            title=Text('Registration', color="white"),
            bgcolor="#132D46",
        ),
        Container(
            alignment=alignment.center,
            expand=True,
            content=Column(
                alignment=alignment.center,
                horizontal_alignment="center",
                controls=[
                    reg_main,
                ]
            )
        )
    )
    page.update()

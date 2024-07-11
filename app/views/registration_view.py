import flet as ft
from app.controllers.user_controller import UserController
from navigation_view import navigate_to, create_navigation_drawer


class UserWidget(ft.UserControl):
    def __init__(self, title: str, sub_title: str, btn_name: str, link: str, navigate_to_login):
        self.title = title
        self.sub_title = sub_title
        self.btn_name = btn_name
        self.link = link
        self.navigate_to_login = navigate_to_login
        self.user_controller = UserController()  # Inicjalizacja kontrolera użytkownika
        super().__init__()

    def InputTextField(self, text: str, hide: bool, ref):
        return ft.Container(
            alignment=ft.alignment.center,
            content=ft.TextField(
                height=58,
                width=300,
                bgcolor="#f0f3f6",
                text_size=14,
                color="black",
                border_color="transparent",
                hint_text=text,
                filled=True,
                cursor_color="black",
                hint_style=ft.TextStyle(
                    size=13,
                    color="black",
                ),
                password=hide,
                ref=ref  # Dodanie referencji do pola tekstowego
            ),
        )

    def SignInOption(self, path: str, name: str):
        return ft.Container(
            content=ft.ElevatedButton(
                content=ft.Row(
                    alignment="center",
                    spacing=4,
                    controls=[
                        ft.Image(
                            src=path,
                            width=35,
                            height=35,
                        ),
                        ft.Text(
                            name,
                            color="black",
                            size=12,
                            weight="bold",
                        )
                    ],
                ),
                style=ft.ButtonStyle(
                    shape={
                        "": ft.RoundedRectangleBorder(radius=8),
                    },
                    bgcolor={
                        "": "#f0f3f6",
                    }
                ),
            ),
        )

    def show_dialog(self, page, title, content, title_color, on_close):
        dlg_modal = ft.AlertDialog(
            modal=True,
            title=ft.Text(title, color=title_color),
            content=ft.Text(content),
            actions=[
                ft.TextButton("OK", on_click=lambda e: [page.close(dlg_modal), on_close(e)]),
            ],
            actions_alignment=ft.MainAxisAlignment.END,
        )
        page.open(dlg_modal)

    def register(self, e):
        email = self.email_input.current.value
        password = self.password_input.current.value
        confirm_password = self.confirm_password_input.current.value

        # Wywołanie metody rejestracji w kontrolerze
        result = self.user_controller.register_user(email, password, confirm_password)

        # Obsługa wyniku rejestracji
        if result["status"] == "error":
            self.show_dialog(e.page, "Error", result["message"], ft.colors.RED, lambda _: None)
        else:
            self.email_input.current.value = ""
            self.password_input.current.value = ""
            self.confirm_password_input.current.value = ""
            self.show_dialog(e.page, "Success", result["message"], ft.colors.GREEN,
                             lambda e: navigate_to(e.page, "Login"))

        e.page.update()

    def build(self):
        # Definiowanie referencji do pól tekstowych
        self.email_input = ft.Ref[ft.TextField]()
        self.password_input = ft.Ref[ft.TextField]()
        self.confirm_password_input = ft.Ref[ft.TextField]()

        self._title = ft.Container(
            alignment=ft.alignment.center,
            content=ft.Text(
                self.title,
                size=24,
                text_align="center",
                weight="bold",
                color="black",
            )
        )

        self._sub_title = ft.Container(
            alignment=ft.alignment.center,
            content=ft.Text(
                self.sub_title,
                size=18,
                text_align="center",
                color="black",
            )
        )

        self._link = ft.Container(
            alignment=ft.alignment.center,
            content=ft.Row(
                alignment="center",
                controls=[
                    ft.Text("Already have an account?", size=12, color="black"),
                    ft.Container(
                        content=ft.Text(
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

        self._sign_up = ft.Container(
            content=ft.ElevatedButton(
                on_click=self.register,  # Wywołanie funkcji rejestracji
                content=ft.Text(
                    self.btn_name,
                    size=14,
                    weight="bold",
                ),
                bgcolor="black",
                color="white",
                style=ft.ButtonStyle(
                    shape={
                        "": ft.RoundedRectangleBorder(radius=8)
                    },
                ),
                height=58,
                width=300,
            )
        )

        class DividerWithText(ft.Container):
            def __init__(self, text):
                super().__init__(
                    content=ft.Row(
                        controls=[
                            ft.Container(width=120, height=1, bgcolor="black"),
                            ft.Text(text, color="black", weight='w400'),
                            ft.Container(width=120, height=1, bgcolor="black"),
                        ],
                        alignment='center',
                        spacing=10,
                    )
                )

        return ft.Column(
            horizontal_alignment="center",
            controls=[
                self._title,
                self._sub_title,
                ft.Container(padding=5),
                ft.Column(
                    spacing=15,
                    controls=[
                        self.InputTextField("Email", False, self.email_input),  # Pole tekstowe email z referencją
                        self.InputTextField("Password", True, self.password_input),  # Pole tekstowe hasło z referencją
                        self.InputTextField("Confirm Password", True, self.confirm_password_input),
                        # Pole tekstowe potwierdzenia hasła z referencją
                    ],
                ),
                ft.Container(padding=3),
                self._sign_up,
                ft.Container(padding=3),
                ft.Column(
                    horizontal_alignment="center",
                    controls=[
                        DividerWithText("or"),
                        self.SignInOption("../assets/icon.png", "Facebook"),
                        self.SignInOption("../assets/icon.png", "Google"),
                    ],
                ),
                ft.Container(padding=5),
                self._link,
            ],
        )


def registration_page(page: ft.Page):
    def _main_column():
        return ft.Container(
            width=320,
            height=700,
            bgcolor="#ffffff",
            padding=16,
            border_radius=35,
            content=ft.Column(
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
    reg_main.content.controls.append(ft.Container(padding=15))
    reg_main.content.controls.append(user_widget)

    drawer = create_navigation_drawer(page)
    page.add(
        ft.AppBar(
            ft.Row(
                controls=[
                    ft.IconButton(
                        icon=ft.icons.MENU_ROUNDED,
                        icon_size=25,
                        icon_color="white",
                        on_click=lambda e: page.open(drawer),
                    ),
                ],
            ),
            title=ft.Text('Registration', color="white"),
            bgcolor="black",
        ),
        ft.Container(
            alignment=ft.alignment.center,
            expand=True,
            content=ft.Column(
                alignment=ft.alignment.center,
                horizontal_alignment="center",
                controls=[
                    reg_main,
                ]
            )
        )
    )
    page.update()

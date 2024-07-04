import flet
from flet import *
from navigation import navigate_to, create_navigation_drawer


class UserWidget(UserControl):
    def __init__(self, title: str, sub_title: str, btn_name: str, link: str, forgot_password: str, navigate_to_registration):
        super().__init__()
        self.title = title
        self.sub_title = sub_title
        self.btn_name = btn_name
        self.link = link
        self.forgot_password = forgot_password
        self.navigate_to_registration = navigate_to_registration

    def InputTextField(self, text: str, hide: bool):
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
                password=hide
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

    def build(self):
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
                    Text("Don't have an account?", size=12, color="black"),
                    Container(
                        content=Text(
                            self.link,
                            size=12,
                            color="green",
                            weight="bold",
                        ),
                        on_click=self.navigate_to_registration,
                    )
                ]
            )
        )

        self._forgot_password = Container(
            alignment=alignment.center_right,
            content=Text(
                self.forgot_password,
                size=12,
                color="green",
                weight="bold",
            )
        )

        self._sign_in = Container(
            content=ElevatedButton(
                on_click=None,
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
                Container(padding=5),
                Column(
                    spacing=15,
                    controls=[
                        self.InputTextField("Email", False),
                        self.InputTextField("Password", True),
                        self._forgot_password,
                    ],
                ),
                Container(padding=3),
                self._sign_in,
                Container(padding=3),
                Column(
                    horizontal_alignment="center",
                    controls=[
                        DividerWithText("or"),
                        self.SignInOption("./assets/icon.png", "Facebook"),
                        self.SignInOption("./assets/icon.png", "Google"),
                    ],
                ),
                Container(padding=5),
                self._link,
            ],
        )

def login_page(page: Page):
    def _main_column():
        return Container(
            width=320,
            height=650,
            bgcolor="#ffffff",
            padding=16,
            border_radius=35,
            content=Column(
                spacing=25,
                horizontal_alignment="center",
            )
        )

    _sign_in_ = UserWidget(
        "Welcome Back!",
        "Enter your account details below",
        "Sign In",
        "Sign Up",
        "Forgot Password?",
        lambda e: navigate_to(page, "Register")
    )

    _sign_in_main = _main_column()
    _sign_in_main.content.controls.append(Container(padding=15))
    _sign_in_main.content.controls.append(_sign_in_)

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
            title=Text('Login', color="white"),
            bgcolor="black",
        ),
        Column(
            alignment=alignment.center,
            horizontal_alignment="center",
            spacing=25,
            controls=[
                _sign_in_main,
            ]
        )
    )
    page.update()




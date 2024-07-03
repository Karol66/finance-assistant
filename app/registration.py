import flet
from flet import *

class UserWidget(UserControl):
    def __init__(self, title: str, sub_title: str, btn_name: str, link: str):
        self.title = title
        self.sub_title = sub_title
        self.btn_name = btn_name
        self.link = link
        super().__init__()

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
                    Text("Already have an account?", size=12, color="black"),
                    Text(
                        self.link,
                        size=12,
                        color="green",
                        weight="bold",
                    )
                ]
            )
        )

        self._sign_up = Container(
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
                        self.InputTextField("Confirm Password", True),
                    ],
                ),
                Container(padding=3),
                self._sign_up,
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

def main(page: Page):
    page.title = "Register"
    page.bgcolor = "#f0f3f6"
    page.horizontal_alignment = "center"
    page.vertical_alignment = "center"

    def _main_column():
        return Container(
            width=320,
            height=700,
            bgcolor="#ffffff",
            padding=16,
            border_radius=35,
            content=Column(
                spacing=25,
                horizontal_alignment="center",
            )
        )

    _register_ = UserWidget(
        "Registration",
        "Register your data below",
        "Register",
        "Log In"
    )

    _reg_main = _main_column()
    _reg_main.content.controls.append(Container(padding=15))
    _reg_main.content.controls.append(_register_)

    page.add(
        Column(
            alignment=alignment.center,
            horizontal_alignment="center",
            spacing=25,
            controls=[
                _reg_main,
            ]
        )
    )

if __name__ == "__main__":
    flet.app(target=main, assets_dir="assets")

app(main)

from flet import *
import flet

# Definicja klasy która tworzy pola tekstowe
class Input(Container):
    def __init__(self, icon, hint_text, password=False):
        self.hint_text = hint_text
        self.icon = icon
        self.password = password
        super().__init__(
            content=Row(
                controls=[
                    Icon(
                        self.icon,
                        color='#FFFFFF',
                    ),
                    TextField(
                        border='none',
                        color='#FFFFFF',
                        cursor_color='#FFFFFF',
                        height=40,
                        width=250,
                        text_style=TextStyle(
                            size=18,
                            weight='w400',
                        ),
                        password=self.password,
                        hint_text=self.hint_text,
                        hint_style=TextStyle(
                            size=18,
                            weight='w500',
                            color='#FFFFFF',
                        )
                    )
                ],
                alignment='center',
            ),
            border=Border(bottom=BorderSide(1, '#FFFFFF')),
            width=250
        )

# Definicja klasy tworzącej przyciski z funkcją hover
class Button(Container):
    def __init__(self, text, width, bgcolor="transparent", hover_bgcolor="transparent", icon=None):
        super().__init__()
        self.original_bgcolor = bgcolor
        self.hover_bgcolor = hover_bgcolor
        controls = [
            Icon(name=icon, color="white") if icon else None,
            Text(
                text,
                color='white',
                weight='w400',
            ),
        ]
        controls = [ctrl for ctrl in controls if ctrl is not None]
        self.button = Container(
            content=Row(
                controls=controls,
                alignment='center',
                spacing=10,
            ),
            border=border.all(1, 'white') if not bgcolor else None,
            border_radius=border_radius.all(15),
            padding=padding.only(15, 8, 15, 8),
            alignment=alignment.center,
            on_hover=self.Hover,
            animate=animation.Animation(250),
            width=width,
            bgcolor=bgcolor
        )
        self.content = self.button

    def Hover(self, e):
        if e.data == "true":
            self.button.bgcolor = self.hover_bgcolor
        else:
            self.button.bgcolor = self.original_bgcolor
        self.button.update()

# Definicja klasy która tworzy linię z tekstem pośrodku (linia dla or)
class DividerWithText(Container):
    def __init__(self, text):
        super().__init__(
            content=Row(
                controls=[
                    Container(width=100, height=1, bgcolor="white"),
                    Text(text, color="white", weight='w400'),
                    Container(width=100, height=1, bgcolor="white"),
                ],
                alignment='center',
                spacing=10,
            )
        )

def navigate_to_login(e):
    e.page.go("/app/login")


# Główny kontener zawierający wszystkie elementy interfejsu
body = Container(
    content=Column([
        Text("Welcome!", size=32, color="white", weight="bold"),
        Text("Please sign up to create an account", size=16, color="white", weight="normal"),
        Input(icons.PERSON, hint_text="Full Name"),
        Input(icons.EMAIL, hint_text="Email"),
        Input(icons.PHONE, hint_text="Phone"),
        Input(icons.LOCK, hint_text="Password", password=True),
        Input(icons.LOCK, hint_text="Confirm Password", password=True),
        Container(height=2),
        Button("Sign Up", width=300, bgcolor="#27AE60", hover_bgcolor="#1e8449"),
        DividerWithText("or"),
        Button("Sign Up with Facebook", width=250, bgcolor="#3498DB", hover_bgcolor="#217dbb", icon=icons.FACEBOOK),
        Button("Sign Up with Google", width=250, bgcolor="#E67E22", hover_bgcolor="#d35400", icon=icons.MAIL),
        Row([
            Text("Already have an account? ", color="#FFFFFF", weight='w400'),
            Container(
                content=Text("Log In", color="#F1C40F", weight='w400'),
                on_click=navigate_to_login
            )
        ], alignment='center')
    ], spacing=15, alignment='center', horizontal_alignment='center'),
    width=360,
    height=650,
    alignment=alignment.center,
    padding=padding.all(20),
    bgcolor='#1B1B1B',
    border_radius=border_radius.all(30),
)

# Funkcja zarządzająca stroną
def manage(page: flet.Page):
    page.bgcolor = '#232323'
    page.padding = 0
    page.add(Container(
        content=body,
        alignment=alignment.center,
        expand=True
    ))

flet.app(target=manage)

import flet
from flet import *
from app.login import login_view
from app.registration import registration_view

def main(page: Page) -> None:
    page.title = 'My application'

    def route_change(e: RouteChangeEvent) -> None:
        page.views.clear()

        # Home view
        if page.route == '/':
            page.views.append(
                View(
                    route='/',
                    controls=[
                        AppBar(title=Text('Home'), bgcolor='blue'),
                        Text(value='Home', size=30, color='white'),
                        ElevatedButton(text='Go to login', on_click=lambda _: page.go('/login'))
                    ],
                    vertical_alignment=MainAxisAlignment.CENTER,
                    horizontal_alignment=CrossAxisAlignment.CENTER,
                    spacing=26,
                    bgcolor='#232323',
                )
            )

        elif page.route == '/login':
            page.views.append(
                View(
                    route='/login',
                    controls=[
                        AppBar(title=Text('Login'), bgcolor='blue'),
                        Container(
                            content=login_view(),
                            alignment=alignment.center,
                            expand=True
                        ),
                        ElevatedButton(text='Go back', on_click=lambda _: page.go('/'))
                    ],
                    vertical_alignment=MainAxisAlignment.CENTER,
                    horizontal_alignment=CrossAxisAlignment.CENTER,
                    spacing=26,
                    bgcolor='#232323',
                )
            )

        elif page.route == '/registration':
            page.views.append(
                View(
                    route='/registration',
                    controls=[
                        AppBar(title=Text('Sign Up'), bgcolor='blue'),
                        Container(
                            content=registration_view(),
                            alignment=alignment.center,
                            expand=True
                        ),
                    ],
                    vertical_alignment=MainAxisAlignment.CENTER,
                    horizontal_alignment=CrossAxisAlignment.CENTER,
                    spacing=26,
                    bgcolor='#232323',
                )
            )

        page.update()

    page.on_route_change = route_change
    page.go(page.route)

if __name__ == '__main__':
    flet.app(target=main)

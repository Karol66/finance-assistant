from django.contrib.auth.views import LogoutView
from django.urls import path
from .views import register, CustomLoginView, logout_view, home

urlpatterns = [
    path('', home, name='home'),
    path('register/', register, name='register'),
    path('login/', CustomLoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(next_page='home'), name='logout'),  # LogoutView obsłuży wylogowanie
]
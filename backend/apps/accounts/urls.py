from django.urls import path
from .views import account_list, account_create, account_update, account_delete

urlpatterns = [
    path('', account_list, name='account_list'),  # Lista kont (GET)
    path('create/', account_create, name='account_create'),  # Tworzenie konta (POST)
    path('<int:pk>/edit/', account_update, name='account_update'),  # Edycja konta (PUT)
    path('<int:pk>/delete/', account_delete, name='account_delete'),  # Usuwanie konta (DELETE)
]

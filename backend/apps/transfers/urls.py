from django.urls import path
from .views import transfer_list, transfer_create, transfer_update, transfer_delete

urlpatterns = [
    path('', transfer_list, name='transfer_list'),  # Lista przelewów (GET)
    path('create/', transfer_create, name='transfer_create'),  # Tworzenie przelewu (POST)
    path('<int:pk>/edit/', transfer_update, name='transfer_update'),  # Edycja przelewu (PUT)
    path('<int:pk>/delete/', transfer_delete, name='transfer_delete'),  # Usuwanie przelewu (DELETE)
]

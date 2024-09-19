from django.urls import path
from .views import notification_list, notification_create, notification_update, notification_delete

urlpatterns = [
    path('', notification_list, name='notification_list'),  # Lista powiadomień (GET)
    path('create/', notification_create, name='notification_create'),  # Tworzenie powiadomienia (POST)
    path('<int:pk>/edit/', notification_update, name='notification_update'),  # Edycja powiadomienia (PUT)
    path('<int:pk>/delete/', notification_delete, name='notification_delete'),  # Usuwanie powiadomienia (DELETE)
]

from django.urls import path
from .views import payment_list, payment_create, payment_update, payment_delete

urlpatterns = [
    path('', payment_list, name='payment_list'),  # Lista płatności (GET)
    path('create/', payment_create, name='payment_create'),  # Tworzenie płatności (POST)
    path('<int:pk>/edit/', payment_update, name='payment_update'),  # Edycja płatności (PUT)
    path('<int:pk>/delete/', payment_delete, name='payment_delete'),  # Usuwanie płatności (DELETE)
]

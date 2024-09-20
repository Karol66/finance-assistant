from django.urls import path
from .views import transfer_create, transfer_update, transfer_delete, transfer_list, account_transfer

urlpatterns = [
    path('', transfer_list, name='transfer_list'),
    path('create/', transfer_create, name='transfer_create'),
    path('<int:pk>/edit/', transfer_update, name='transfer_update'),
    path('<int:pk>/delete/', transfer_delete, name='transfer_delete'),
    path('account-transfer/', account_transfer, name='account_transfer'),  # Nowy endpoint dla przelewu między kontami
]

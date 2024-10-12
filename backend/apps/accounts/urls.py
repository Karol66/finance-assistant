from django.urls import path
from .views import account_list, account_create, account_update, account_delete

urlpatterns = [
    path('accounts/', account_list, name='account_list'),
    path('accounts/create/', account_create, name='account_create'),
    path('accounts/<int:pk>/edit/', account_update, name='account_update'),
    path('accounts/<int:pk>/delete/', account_delete, name='account_delete'),
]

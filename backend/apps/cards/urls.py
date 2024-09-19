from django.urls import path
from .views import card_list, card_create, card_update, card_delete

urlpatterns = [
    path('', card_list, name='card_list'),
    path('create/', card_create, name='card_create'),
    path('<int:pk>/edit/', card_update, name='card_update'),
    path('<int:pk>/delete/', card_delete, name='card_delete'),
]

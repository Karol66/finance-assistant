from django.urls import path
from .views import card_list, card_create, card_update, card_delete, card_detail

urlpatterns = [
    path('cards/', card_list, name='card_list'),
    path('cards/<int:pk>/', card_detail, name='card_detail'),
    path('cards/create/', card_create, name='card_create'),
    path('cards/<int:pk>/edit/', card_update, name='card_update'),
    path('cards/<int:pk>/delete/', card_delete, name='card_delete'),
]

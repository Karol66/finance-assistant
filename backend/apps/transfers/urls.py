from django.urls import path
from .views import transfer_create, transfer_update, transfer_delete, transfer_list, transfer_detail

urlpatterns = [
    path('transfers/', transfer_list, name='transfer_list'),
    path('transfers/create/', transfer_create, name='transfer_create'),
    path('transfers/<int:pk>/', transfer_detail, name='transfer_detail'),
    path('transfers/<int:pk>/edit/', transfer_update, name='transfer_update'),
    path('transfers/<int:pk>/delete/', transfer_delete, name='transfer_delete'),
]

from django.urls import path
from .views import transfer_create, transfer_update, transfer_delete, transfer_list, transfer_detail, \
    get_category_from_transfer, get_account_from_transfer, regular_transfer_list

urlpatterns = [
    path('transfers/', transfer_list, name='transfer_list'),
    path('transfers/create/', transfer_create, name='transfer_create'),
    path('transfers/<int:pk>/', transfer_detail, name='transfer_detail'),
    path('transfers/<int:pk>/edit/', transfer_update, name='transfer_update'),
    path('transfers/<int:pk>/delete/', transfer_delete, name='transfer_delete'),
    path('transfers/<int:transfer_id>/category/', get_category_from_transfer, name='get_category_from_transfer'),
    path('transfers/<int:transfer_id>/account/', get_account_from_transfer, name='get_account_from_transfer'),
    path('transfers/regular/', regular_transfer_list, name='regular_transfer_list'),
]

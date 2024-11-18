from django.urls import path
from .views import transfer_create, transfer_update, transfer_delete, transfer_list, transfer_detail, \
    get_category_from_transfer, get_account_from_transfer, regular_transfer_list, regular_transfer_create, \
    regular_transfer_update, regular_transfer_detail, regular_transfer_delete, transfer_list_grouped_by_category, \
    calculate_profit_loss, generate_regular_transfers

urlpatterns = [
    path('transfers/', transfer_list, name='transfer_list'),
    path('transfers/create/', transfer_create, name='transfer_create'),
    path('transfers/<int:pk>/', transfer_detail, name='transfer_detail'),
    path('transfers/<int:pk>/edit/', transfer_update, name='transfer_update'),
    path('transfers/<int:pk>/delete/', transfer_delete, name='transfer_delete'),
    path('transfers/<int:transfer_id>/category/', get_category_from_transfer, name='get_category_from_transfer'),
    path('transfers/<int:transfer_id>/account/', get_account_from_transfer, name='get_account_from_transfer'),
    path('transfers/grouped/', transfer_list_grouped_by_category, name='transfer_list_grouped_by_category'),
    path('transfers/calculate-profit-loss/', calculate_profit_loss, name='calculate-profit-loss'),

    path('transfers/regular/', regular_transfer_list, name='regular_transfer_list'),
    path('transfers/regular/create/', regular_transfer_create, name='regular_transfer_create'),
    path('transfers/regular/<int:pk>/', regular_transfer_detail, name='regular_transfer_detail'),
    path('transfers/regular/<int:pk>/edit/', regular_transfer_update, name='regular_transfer_update'),
    path('transfers/regular/<int:pk>/delete/', regular_transfer_delete, name='regular_transfer_delete'),
    path('transfers/regular/generate/', generate_regular_transfers, name='generate_regular_transfers'),
]

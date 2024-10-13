from django.urls import path
from .views import payment_list, payment_create, payment_update, payment_delete, payment_detail

urlpatterns = [
    path('payments/', payment_list, name='payment_list'),
    path('payments/<int:pk>/', payment_detail, name='payment_detail'),
    path('payments/create/', payment_create, name='payment_create'),
    path('payments/<int:pk>/edit/', payment_update, name='payment_update'),
    path('payments/<int:pk>/delete/', payment_delete, name='payment_delete'),
]

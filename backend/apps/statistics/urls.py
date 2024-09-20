from django.urls import path
from .views import create_statistics, statistics_list, przewidywanie_oszczednosci_view

urlpatterns = [
    path('', statistics_list, name='statistics_list'),
    path('create/', create_statistics, name='create_statistics'),
    path('predict/', przewidywanie_oszczednosci_view, name='predict_savings'),
]

from django.urls import path
from .views import create_statistics, statistics_list, przewidywanie_oszczednosci_view

urlpatterns = [
    path('statistics/', statistics_list, name='statistics_list'),
    path('statistics/create/', create_statistics, name='create_statistics'),
    path('statistics/predict/', przewidywanie_oszczednosci_view, name='predict_savings'),
]

from django.urls import path
from .views import create_statistics, statistics_list

urlpatterns = [
    path('', statistics_list, name='statistics_list'),
    path('create/', create_statistics, name='create_statistics'),
]

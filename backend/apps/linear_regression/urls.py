from django.urls import path
from . import views

urlpatterns = [
    path('predict-expenses/', views.predict_expenses, name='predict_expenses'),
    path('predict-income/', views.predict_income, name='predict_income'),
    path('predict-net-savings/', views.predict_net_savings, name='predict_net_savings'),
    path('predict-and-allocate-savings/', views.predict_and_allocate_savings, name='predict_and_allocate_savings'),
]

from django.urls import path
from . import views

urlpatterns = [
    path('predict-savings/', views.predict_savings_for_next_12_months, name='predict-savings'),
    path('propose-saving-strategy/', views.propose_saving_strategy, name='propose-saving-strategy'),
]

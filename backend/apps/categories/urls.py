from django.urls import path
from .views import category_list, category_create, category_update, category_delete, category_detail

urlpatterns = [
    path('categories/', category_list, name='category_list'),
    path('categories/<int:pk>/', category_detail, name='category_detail'),
    path('categories/create/', category_create, name='category_create'),
    path('categories/<int:pk>/edit/', category_update, name='category_update'),
    path('categories/<int:pk>/delete/', category_delete, name='category_delete'),
]

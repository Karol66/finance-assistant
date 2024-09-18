from django.urls import path
from .views import category_list, category_create, category_update, category_delete

urlpatterns = [
    path('', category_list, name='category_list'),
    path('create/', category_create, name='category_create'),  # Ścieżka do tworzenia nowej kategorii
    path('<int:pk>/edit/', category_update, name='category_update'),  # Ścieżka do edycji kategorii
    path('<int:pk>/delete/', category_delete, name='category_delete'),  # Ścieżka do usuwania kategorii
]

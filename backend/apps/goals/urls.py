from django.urls import path
from .views import goal_list, goal_create, goal_update, goal_delete, goal_detail

urlpatterns = [
    path('goals/', goal_list, name='goal_list'),
    path('goals/<int:pk>/', goal_detail, name='goal_detail'),
    path('goals/create/', goal_create, name='goal_create'),
    path('goals/<int:pk>/edit/', goal_update, name='goal_update'),
    path('goals/<int:pk>/delete/', goal_delete, name='goal_delete'),
]

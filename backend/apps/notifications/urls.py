from django.urls import path
from .views import notification_list, notification_create, notification_update, notification_delete, \
    notification_detail, today_notifications_count

urlpatterns = [
    path('notifications/', notification_list, name='notification_list'),
    path('notifications/<int:pk>/', notification_detail, name='notification_detail'),
    path('notifications/create/', notification_create, name='notification_create'),
    path('notifications/<int:pk>/edit/', notification_update, name='notification_update'),
    path('notifications/<int:pk>/delete/', notification_delete, name='notification_delete'),
    path('notifications/today_count/', today_notifications_count, name='today_notifications_count'),
]

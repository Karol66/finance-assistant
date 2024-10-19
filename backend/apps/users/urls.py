from django.urls import path
from .views import register_api, login_api, user_detail
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('register/', register_api, name='register_api'),
    path('login/', login_api, name='login_api'),
    path('user_detail/', user_detail, name='user_detail'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]

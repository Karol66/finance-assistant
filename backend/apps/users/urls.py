from django.urls import path
from .views import register_api, login_api
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('register/', register_api, name='register_api'),
    path('login/', login_api, name='login_api'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]

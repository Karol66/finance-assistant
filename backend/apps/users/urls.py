from django.urls import path
from .views import register_api, login_api, user_detail, update_profile
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('register/', register_api, name='register_api'),
    path('login/', login_api, name='login_api'),
    path('user_detail/', user_detail, name='user_detail'),
    path('update_profile/', update_profile, name='update_profile'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]

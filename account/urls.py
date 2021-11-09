from django.conf.urls import url
from django.conf import settings
from django.urls import path
from . import views

app_name = 'account'

urlpatterns = [
    # path('login/', views.LoginView.as_view(), name="login"),
    path('login/', views.login, name='login'),
    path('logout/', views.LogoutView.as_view(), name='logout'),
    path('signup/', views.signup, name='signup'),
    path('verify-code/<pk>/', views.verify_code, name='verify_code'),
    path('forgot-password/', views.forgot_password, name='forgot_password'),
    path('reset-password/<pk>/', views.reset_password, name='reset-password'),
    path('test-sms/', views.test_sms, name='test-sms')
    # path('activation/<uid>/<token>/', views.user_activation, name='activation'),
    # path('password/reset/confirm/<uid>/<token>/', views.password_reset, name='password-reset'),
    # path('profile/', views.profile_view, name='profile'),
    # path('user/<pk>/', views.user_view, name='user'),
]
from django.urls import path, include
from django.conf.urls import url
from rest_framework import routers, permissions
from rest_framework.schemas import get_schema_view
from . import views

app_name = 'api'
router_v1 = routers.DefaultRouter()
router_v1.register(r'recipe', views.RecipeViewset, basename='recipe')
router_v1.register(r'unbox', views.UnboxingViewset, basename='unbox')

urlpatterns = [
    path('', include(router_v1.urls)),
    path('auth/', include('djoser.urls')),
    path('auth/', include('djoser.urls.authtoken'))
]

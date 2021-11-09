from django.conf.urls import url
from django.urls import path
from . import views

app_name = 'core'

urlpatterns = [
    path('', views.home, name='home'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('users/', views.user_list, name='user_list'),
    path('add-user/', views.user_add, name='user_add'),
    path('edit-user/<pk>/', views.user_edit, name='user_edit'),
    path('delete-user/<pk>/', views.user_delete, name='user_delete'),

    path('ingredient-autocomplete/', views.ingredient_autocomplete, name='ingredient_autocomplete'),
    path('ingredient-search', views.search_ingredient, name='ingredient_search'),
    path('recipes/', views.recipe_list, name='recipe_list'),
    path('recipe/<pk>/', views.recipe_view, name='recipe_detail'),
    path('add-recipe/', views.recipe_add, name='recipe_add'),
    path('edit-recipe/<pk>/', views.recipe_edit, name='recipe_edit'),
    path('delete-recipe/<pk>/', views.recipe_delete, name='recipe_delete'),
    path('recipe-approve/<pk>/', views.recipe_approve, name='recipe_approve'),
    path('recipe-unbox/<pk>/', views.recipe_unbox, name='recipe_unbox'),

    path('unboxing/', views.unboxing_list, name='unboxing_list'),
    path('add-unboxing/', views.unboxing_add, name='unboxing_add'),
    path('edit-unboxing/<pk>/', views.unboxing_edit, name='unboxing_edit'),
    path('delete-unboxing/<pk>/', views.unboxing_delete, name='unboxing_delete'),
]

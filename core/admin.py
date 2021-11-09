from django.contrib import admin
from .models import Recipe, Ingredient


# Register your models here.
@admin.register(Recipe)
class RecipeAdmin(admin.ModelAdmin):
    list_display = ('name', 'chef', 'category', 'approved', 'unbox')
    list_editable = ('approved', 'unbox')
    list_display_links = ('name', )

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj=None):
        # Disable delete button
        return False

    def get_actions(self, request):
        actions = super().get_actions(request)
        if 'delete_selected' in actions:
            del actions['delete_selected']
        return actions


@admin.register(Ingredient)
class IngredientAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')

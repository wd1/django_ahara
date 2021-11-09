from rest_framework.response import Response
from rest_framework import viewsets, status, generics, mixins
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from rest_framework.exceptions import NotFound
from account.models import User
from core.models import Recipe, Unboxing
from .serializers import RecipeSerializer, UnboxingSerializer, SimpleRecipeSerializer


class RecipeViewset(viewsets.ModelViewSet):
    def get_serializer_class(self):
        if self.action == 'like':
            return SimpleRecipeSerializer
        return RecipeSerializer

    def get_queryset(self):
        queryset = Recipe.objects.all()
        return queryset

    @action(["get"], detail=False)
    def main(self, request):
        recipes = Recipe.objects.filter(unbox=True, approved=True)
        serializer = self.get_serializer(recipes, many=True)
        return Response(status=status.HTTP_200_OK, data=serializer.data)

    @action(["get"], detail=False)
    def unbox(self, request):
        recipes = Recipe.objects.filter(unbox=True)
        serializer = self.get_serializer(recipes, many=True)
        return Response(status=status.HTTP_200_OK, data=serializer.data)

    @action(["get"], detail=False)
    def approved(self, request):
        recipes = Recipe.objects.filter(approved=True)
        serializer = self.get_serializer(recipes, many=True)
        return Response(status=status.HTTP_200_OK, data=serializer.data)

    @action(['get'], detail=False)
    def search(self, request):
        keyword = request.GET.get('keyword', '')
        category = request.GET.get('category', 'all')
        is_this_week = request.GET.get('is_this_week', 'yes')
        recipes = Recipe.objects.all()
        if category != 'all':
            recipes = recipes.filter(category=category)
        if is_this_week == 'yes':
            recipes = recipes.filter(is_this_week=True)
        recipes = recipes.filter(name__icontains=keyword)
        serializer = self.get_serializer(recipes, many=True)
        return Response(status=status.HTTP_200_OK, data=serializer.data)

    @action(['patch'], detail=True)
    def like(self, request, pk):
        recipe = self.get_object()
        if recipe.likes.filter(pk=request.user.pk).exists():
            recipe.likes.remove(request.user)
        else:
            recipe.likes.add(request.user)
        serializer = RecipeSerializer(recipe, many=False, context={'request': request})
        return Response(status=status.HTTP_200_OK, data=serializer.data)


class UnboxingViewset(viewsets.ReadOnlyModelViewSet):
    serializer_class = UnboxingSerializer
    queryset = Unboxing.objects.all()

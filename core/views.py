from django.shortcuts import render, redirect
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.contrib import messages
from django.http import JsonResponse
from django.db import transaction, IntegrityError
from django.db.models import Q
from account.models import User
from .forms import UserForm, RecipeForm, RecipePreparationFormSet, RecipeIngredientFormSet, RecipeCookFormSet, \
    RecipeVideoFormSet, UnboxingForm, RecipeLearnMoreForm
from .decorators import admin_required, super_admin_required
from .models import Recipe, RecipePreparation, RecipeIngredients, RecipeCook, RecipeVideo, Unboxing, Ingredient
from ahara.decouple import config
import requests
from django.template.loader import render_to_string

# Create your views here.


def home(request):
    if request.user.is_authenticated:
        return redirect('core:dashboard')
    return render(request, 'core/home.html')


@admin_required
def dashboard(request):
    if request.user.is_chef:
        total_recipes = Recipe.objects.filter(chef=request.user).count()
        approved_recipes = Recipe.objects.filter(chef=request.user, approved=True).count()
    else:
        total_recipes = Recipe.objects.all().count()
        approved_recipes = Recipe.objects.filter(approved=True).count()
    total_chef = User.objects.filter(is_chef=True, is_superuser=False).count()
    total_users = User.objects.filter(is_superuser=False).count()
    return render(request, 'core/dashboard.html', context={
        'total_recipes': total_recipes,
        'approved_recipes': approved_recipes,
        'total_chef': total_chef,
        'total_users': total_users
    })


@admin_required
def user_list(request):
    page = request.GET.get('page', 1)
    search = request.GET.get('search', '')
    is_chef = int(request.GET.get('chef', '0'))
    user_list = User.objects.filter(is_superuser=False)
    if search:
        user_list = user_list.filter(Q(first_name__icontains=search) | Q(last_name__icontains=search) | Q(phone_number__icontains=search))
    if is_chef == 1:
        user_list = user_list.filter(is_chef=1)
    paginator = Paginator(user_list, 10)
    try:
        users = paginator.page(page)
    except PageNotAnInteger:
        users = paginator.page(1)
    except EmptyPage:
        users = paginator.page(paginator.num_pages)
    return render(request, 'core/user-list.html', context={'users': users, 'search': search})


@super_admin_required(raise_exception=True)
def user_add(request, item=None):
    if request.method == 'POST':
        form = UserForm(request.POST, request.FILES, instance=item)
        if form.is_valid():
            form.save(commit=True)
            if item:
                messages.success(request, 'User updated successfully')
            else:
                messages.success(request, 'New user added successfully')
            return redirect('core:user_list')
    else:
        form = UserForm(instance=item)
    return render(request, 'core/user-add.html', context={'form': form, 'item': item})


@super_admin_required(raise_exception=True)
def user_edit(request, pk):
    item = User.objects.get(pk=pk)
    return user_add(request, item)


@super_admin_required(raise_exception=True)
def user_delete(request, pk):
    user = User.objects.get(pk=pk)

    msg = '{} deleted successfully'.format(user.fullname)
    user.delete()
    return JsonResponse({'status': 1, 'msg': msg})


@admin_required
def recipe_list(request):
    search = request.GET.get('search', '')
    category = request.GET.get('category', '')
    period = int(request.GET.get('period', '0'))
    recipe_list = Recipe.objects.all().order_by('-created')
    if search:
        recipe_list = recipe_list.filter(Q(name__icontains=search) | Q(recipe_ingredients__ingredient__icontains=search))
    if category:
        recipe_list = recipe_list.filter(category=category)
    if period == 1:
        recipe_list = recipe_list.filter(is_this_week=True)
    elif period == 2:
        recipe_list = recipe_list.filter(is_this_week=False)
    page = request.GET.get('page', 1)
    if not request.user.is_superuser:
        recipe_list = recipe_list.filter(chef=request.user)
    paginator = Paginator(recipe_list, 10)
    try:
        recipes = paginator.page(page)
    except PageNotAnInteger:
        recipes = paginator.page(1)
    except EmptyPage:
        recipes = paginator.page(paginator.num_pages)
    return render(request, 'core/recipe-list.html',
                  context={
                      'recipes': recipes,
                      'search': search,
                      'category': category,
                      'period': period
                  })


@admin_required
def ingredient_autocomplete(request):
    keyword = request.GET.get('qry', '')
    ingredients = list(Ingredient.objects.filter(name__istartswith=keyword).values_list('name', flat=True))
    return JsonResponse({'status': 1, 'data': ingredients})


def search_ingredient(request):
    keyword = request.GET.get('keyword', '')
    if len(keyword) < 1:
        return JsonResponse({'status': 0, 'msg': 'Enter ingredient name please'})
    resp = requests.get('https://api.nal.usda.gov/fdc/v1/foods/search?api_key={}&query={}&dataType=Foundation'.format(config('USDA_API_KEY'), keyword))
    if resp.status_code == 200:
        totalHits = resp.json()['totalHits']
        if totalHits < 1:
            return JsonResponse({'status': 0, 'msg': 'Can not find nutrition information'})
        food = resp.json()['foods'][0]
        nutritions = food['foodNutrients']
        html = render_to_string('core/nutrition-detail.html', context={'nutrients': nutritions})
        return JsonResponse({'status': 1, 'html': html, 'name': food['description']})
    return JsonResponse({'status': 0, 'msg': 'Something went wrong'})

@admin_required
def recipe_add(request, item=None):
    if request.method == 'POST':
        form = RecipeForm(request.POST, request.FILES, instance=item)
        is_recipe_prep_valid = True
        is_ingredient_valid = True
        # is_recipe_cook_valid = True
        is_recipe_video_valid = True
        recipe_prep_formset = RecipePreparationFormSet(request.POST,
                                                       prefix='recipe-prep',
                                                       queryset=item.preparations.all() if item else RecipePreparation.objects.none())
        is_recipe_prep_valid = recipe_prep_formset.is_valid()
        recipe_ingredient_formset = RecipeIngredientFormSet(request.POST,
                                                            prefix='recipe-ingredient',
                                                            queryset=item.recipe_ingredients.all() if item else RecipeIngredients.objects.none())
        is_ingredient_valid = recipe_ingredient_formset.is_valid()
        learn_more_form = RecipeLearnMoreForm(request.POST, prefix='learn-more', instance=item)
        # recipe_cook_formset = RecipeCookFormSet(request.POST,
        #                                         prefix='recipe-cook',
        #                                         queryset=item.cook_steps.all() if item else RecipeCook.objects.none())
        # is_recipe_cook_valid = recipe_cook_formset.is_valid()
        recipe_video_formset = RecipeVideoFormSet(request.POST, request.FILES,
                                                  prefix='recipe-video',
                                                  queryset=item.videos.all() if item else RecipeVideo.objects.none()
                                                  )
        is_recipe_video_valid = recipe_video_formset.is_valid()
        if form.is_valid() and is_recipe_prep_valid and is_ingredient_valid and is_recipe_video_valid and learn_more_form.is_valid():
            with transaction.atomic():
                recipe = form.save(commit=False)
                if not item:
                    recipe.chef = request.user
                recipe.save()

                recipe_preps = recipe_prep_formset.save(commit=False)
                for obj in recipe_prep_formset.deleted_objects:
                    obj.delete()
                for i in range(0, len(recipe_preps)):
                    recipe_preps[i].recipe = recipe
                    recipe_preps[i].save()

                recipe_ingredients = recipe_ingredient_formset.save(commit=False)
                for obj in recipe_ingredient_formset.deleted_objects:
                    obj.delete()
                for i in range(0, len(recipe_ingredients)):
                    recipe_ingredients[i].recipe = recipe
                    recipe_ingredients[i].save()

                # recipe_cook_steps = recipe_cook_formset.save(commit=False)
                # for obj in recipe_cook_formset.deleted_objects:
                #     obj.delete()
                # for i in range(0, len(recipe_cook_steps)):
                #     recipe_cook_steps[i].recipe = recipe
                #     recipe_cook_steps[i].save()

                learn_more = learn_more_form.save(commit=False)
                recipe.learn_more_title = learn_more.learn_more_title
                recipe.learn_more_desc = learn_more.learn_more_desc
                recipe.save()

                recipe_videos = recipe_video_formset.save(commit=False)
                for obj in recipe_video_formset.deleted_objects:
                    obj.delete()
                for i in range(0, len(recipe_videos)):
                    recipe_videos[i].recipe = recipe
                    recipe_videos[i].save()

                if item:
                    msg = '{} updated successfully'.format(recipe.name.capitalize())
                else:
                    msg = '{} created successfully'.format(recipe.name.capitalize())
                messages.success(request, msg)
                return redirect('core:recipe_list')

    else:
        form = RecipeForm(instance=item)
        recipe_prep_formset = RecipePreparationFormSet(prefix='recipe-prep',
                                                       queryset=item.preparations.all() if item else RecipePreparation.objects.none())
        recipe_ingredient_formset = RecipeIngredientFormSet(prefix='recipe-ingredient',
                                                            queryset=item.recipe_ingredients.all() if item else RecipeIngredients.objects.none())
        # recipe_cook_formset = RecipeCookFormSet(prefix='recipe-cook',
        #                                         queryset=item.cook_steps.all() if item else RecipeCook.objects.none())
        learn_more_form = RecipeLearnMoreForm(prefix='learn-more', instance=item)
        recipe_video_formset = RecipeVideoFormSet(prefix='recipe-video',
                                                  queryset=item.videos.all() if item else RecipeVideo.objects.none())
    return render(request, 'core/recipe-add.html',
                  context={'form': form,
                           'recipe_prep_formset': recipe_prep_formset,
                           'recipe_ingredient_formset': recipe_ingredient_formset,
                           # 'recipe_cook_formset': recipe_cook_formset,
                           'learn_more_form': learn_more_form,
                           'recipe_video_formset': recipe_video_formset,
                           'item': item,
                           'USDA_API_KEY': config('USDA_API_KEY')
                           })


@admin_required
def recipe_view(request, pk):
    recipe = Recipe.objects.get(pk=pk)
    return render(request, 'core/recipe-view.html',
                  context={'recipe': recipe})


@admin_required
def recipe_edit(request, pk):
    item = Recipe.objects.get(pk=pk)
    return recipe_add(request, item)


@admin_required
def recipe_delete(request, pk):
    item = Recipe.objects.get(pk=pk)

    msg = '{} deleted successfully'.format(item.name)
    item.delete()
    messages.success(request, msg)
    return JsonResponse({'status': 1, 'msg': msg})


@super_admin_required(raise_exception=True)
def recipe_approve(request, pk):
    recipe = Recipe.objects.get(pk=pk)
    approved = True if request.POST.get('approved', 'false') == 'true' else False
    recipe.approved = approved
    msg = '<strong>{}</strong> approved status updated'.format(recipe.name.capitalize())

    # if recipe.approved:
    #     msg = '<strong>{}</strong> has approved'.format(recipe.name.capitalize())
    recipe.save()
    return JsonResponse({'status': 1, 'msg': msg})


@super_admin_required(raise_exception=True)
def recipe_unbox(request, pk):
    recipe = Recipe.objects.get(pk=pk)
    unbox = True if request.POST.get('unbox', 'false') == 'true' else False
    recipe.is_this_week = unbox
    msg = '<strong>{}</strong> status updated'.format(recipe.name.capitalize())

    # if recipe.unbox:
    #     msg = '<strong>{}</strong> unboxed'.format(recipe.name.capitalize())
    recipe.save()
    return JsonResponse({'status': 1, 'msg': msg})


@admin_required
def unboxing_list(request):
    page = request.GET.get('page', 1)
    # unboxing_list = Unboxing.objects.filter(chef=request.user).order_by('-created')
    unboxing_list = Unboxing.objects.all().order_by('-created')
    if not request.user.is_superuser:
        unboxing_list = unboxing_list.filter(chef=request.user)
    paginator = Paginator(unboxing_list, 10)
    try:
        unboxing_videos = paginator.page(page)
    except PageNotAnInteger:
        unboxing_videos = paginator.page(1)
    except EmptyPage:
        unboxing_videos = paginator.page(paginator.num_pages)
    return render(request, 'core/unbox-list.html', context={'unboxing_videos': unboxing_videos})


@admin_required
def unboxing_add(request, item=None):
    if request.method == 'POST':
        form = UnboxingForm(request.POST, request.FILES, instance=item)
        if form.is_valid():
            unboxing = form.save(commit=False)
            if not item:
                unboxing.chef = request.user
            unboxing.save()
            if unboxing.is_current:
                unbox_videos = Unboxing.objects.filter(chef=request.user, is_current=True).exclude(pk=unboxing.pk)\
                    .update(is_current=False)
            if item:
                messages.success(request, 'Unboxing updated successfully')
            else:
                messages.success(request, 'Unboxing added successfully')
            return redirect('core:unboxing_list')
    else:
        form = UnboxingForm(instance=item)

    return render(request, 'core/unbox-add.html', context={'form': form, 'item': item})


@admin_required
def unboxing_edit(request, pk):
    item = Unboxing.objects.get(pk=pk)
    return unboxing_add(request, item)


@admin_required
def unboxing_delete(request, pk):
    item = Unboxing.objects.get(pk=pk)

    msg = '{} deleted successfully'.format(item.video.name)
    item.delete()
    messages.success(request, msg)
    return JsonResponse({'status': 1, 'msg': msg})

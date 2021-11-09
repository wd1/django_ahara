import uuid
from django.db import models
from django.conf import settings
from account.models import User
from .utils import ensure_path_exists
from core.overrides.storage_backend import PrivateMediaStorage
import os


# Create your models here.
class BaseModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    updated = models.DateTimeField(auto_now=True)
    created = models.DateTimeField(auto_now_add=True)
    enabled = models.BooleanField(default=True, )

    @property
    def from_database(self):
        return not self._state.adding

    class Meta:
        abstract = True


class Ingredient(BaseModel):
    name = models.CharField(max_length=255)
    description = models.CharField(max_length=255, null=True, blank=True)

    def __str__(self):
        return self.name


def image_path(instance, filename):
    path = settings.VIDEO_UPLOAD_PATH.format(recipe=instance.name)
    ensure_path_exists(path)
    import os
    return os.path.join(path, filename)


class Recipe(BaseModel):
    CATEGORY_BEVERAGE = 'Beverage'
    CATEGORY_SOUP = 'Soup'
    CATEGORY_SALAD = 'Salad'
    CATEGORY_MAIN = 'Main Dish'
    CATEGORY_SIDE = 'Side Dish'
    CATEGORY_CHIOCE = (
        (CATEGORY_BEVERAGE, 'Beverage'),
        (CATEGORY_SOUP, 'Soup'),
        (CATEGORY_SALAD, 'Salad'),
        (CATEGORY_MAIN, 'Main Dish'),
        (CATEGORY_SIDE, 'Side Dish')
    )
    SERVING_CHOICE = (
        ('1', '1'),
        ('2', '2'),
        ('3', '3'),
        ('4', '4'),
        ('5', '5'),
        ('6', '6'),
        ('7', '7'),
        ('8', '8'),
        ('9', '9'),
        ('10', '10'),
        ('11', '11'),
        ('12', '12'),
        ('13', '13'),
        ('14', '14'),
        ('15', '15')
    )
    chef = models.ForeignKey(User, help_text='Chef', related_name='recipes', on_delete=models.CASCADE)
    name = models.CharField(max_length=255)
    category = models.CharField(choices=CATEGORY_CHIOCE, max_length=50, default=CATEGORY_BEVERAGE)
    description = models.CharField(max_length=255, blank=True, null=True)
    serving = models.CharField(choices=SERVING_CHOICE, blank=True, null=True, max_length=50)
    # min_number_of_people = models.IntegerField(default=0)
    # max_number_of_people = models.IntegerField(default=0)
    # calorie = models.IntegerField(default=0)
    prep_time = models.IntegerField(default=0)
    cooking_time = models.IntegerField(default=0)
    approved = models.BooleanField(default=False)
    unbox = models.BooleanField(default=False)
    image = models.ImageField('Image', upload_to=image_path, storage=PrivateMediaStorage(), blank=True, null=True)
    viewed = models.IntegerField(default=0)
    learn_more_title = models.CharField(max_length=100, blank=True, null=True)
    learn_more_desc = models.TextField(blank=True, null=True)
    is_this_week = models.BooleanField(default=False)
    likes = models.ManyToManyField(User, related_name='likes', blank=True)

    def __str__(self):
        return self.name


def video_path(instance, filename):
    path = settings.VIDEO_UPLOAD_PATH.format(recipe=instance.recipe.name)
    ensure_path_exists(path)
    import os
    return os.path.join(path, filename)


class RecipeVideo(BaseModel):
    recipe = models.ForeignKey(Recipe, related_name='videos', on_delete=models.CASCADE)
    video = models.FileField('Video', upload_to=video_path, storage=PrivateMediaStorage())
    duration = models.FloatField('Duration in seconds', default=0)

    def __str__(self):
        return self.video.name

    @property
    def filename(self):
        return os.path.basename(self.video.name)


class RecipeIngredients(BaseModel):
    recipe = models.ForeignKey(Recipe, related_name='recipe_ingredients', on_delete=models.CASCADE)
    # ingredient = models.ForeignKey(Ingredient, related_name='recipe_ingredients', on_delete=models.CASCADE)
    ingredient = models.CharField(max_length=50)
    unit = models.CharField(max_length=30)

    def __str__(self):
        return '{}-{}'.format(self.recipe.name, self.ingredient)

    def save(self, force_insert=False, force_update=False, using=None, update_fields=None):
        if not Ingredient.objects.filter(name=self.ingredient).exists():
            Ingredient.objects.create(name=self.ingredient)
        super(RecipeIngredients, self).save(force_insert, force_update, using, update_fields)


class RecipePreparation(BaseModel):
    recipe = models.ForeignKey(Recipe, related_name='preparations', on_delete=models.CASCADE)
    detail = models.TextField(blank=True, null=True)
    index = models.IntegerField(default=1)

    def __str__(self):
        return self.detail

    class Meta:
        abstract = False
        ordering = ('index', )


class RecipeCook(BaseModel):
    recipe = models.ForeignKey(Recipe, related_name='cook_steps', on_delete=models.CASCADE)
    detail = models.TextField(blank=True, null=True)
    index = models.IntegerField(default=1)

    def __str__(self):
        return self.detail

    class Meta:
        abstract = False
        ordering = ('index',)


# class RecipeLearnMore(BaseModel):
#     recipe = models.ForeignKey(Recipe, related_name='learn_more', on_delete=models.CASCADE)
#     title = models.CharField(max_length=100)
#     detail = models.TextField(blank=True, null=True)


def unboxing_path(instance, filename):
    path = settings.UNBOXING_UPLOAD_PATH.format(pk=instance.chef.id)
    ensure_path_exists(path)
    import os
    return os.path.join(path, filename)


class Unboxing(BaseModel):
    chef = models.ForeignKey(User, help_text='Chef', related_name='unboxing_videos', on_delete=models.CASCADE)
    video = models.FileField('Lesson', upload_to=unboxing_path, storage=PrivateMediaStorage())
    timestamp = models.DateTimeField(auto_now_add=True)
    is_current = models.BooleanField(default=False)

    def __str__(self):
        return self.video.name

    @property
    def filename(self):
        return os.path.basename(self.video.name)

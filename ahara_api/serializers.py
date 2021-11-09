from django.contrib.auth import get_user_model
from django.db import IntegrityError, transaction
from django.contrib.auth.password_validation import validate_password
from django.core import exceptions as django_exceptions
from djoser.conf import settings
from djoser.serializers import UserSerializer
from rest_framework import serializers, exceptions
from rest_framework.validators import UniqueValidator
from rest_framework.exceptions import ValidationError
from account.models import User
from core.models import Recipe, RecipeVideo, RecipeCook, RecipeIngredients, RecipePreparation, Unboxing
from random import randint


class UidAndOtpSerializer(serializers.Serializer):
    phone_number = serializers.CharField()
    otp = serializers.CharField()

    default_error_messages = {
        "invalid_otp": "Invalid token for given user",
        "invalid_phone_number": "Invalid phone number or user doesn't exist"
    }

    def validate(self, attrs):
        validate_data = super().validate(attrs)

        try:
            phone_number = self.initial_data.get("phone_number", "")
            self.user = User.objects.get(phone_number=phone_number)
        except (User.DoesNotExist, ValueError, TypeError, OverflowError):
            key_error = "invalid_phone_number"
            raise ValidationError({"error": [self.error_messages[key_error]]}, code=key_error)

        is_otp_valid = True if str(self.user.otp) == self.initial_data.get("otp", "") else False
        if is_otp_valid:
            return validate_data
        else:
            key_error = "invalid_otp"
            raise ValidationError({"error": [self.error_messages[key_error]]}, code=key_error)


class ActivationSerializer(UidAndOtpSerializer):
    default_error_messages = {
        "stale_token": "Stale OTP code for given user"
    }

    def validate(self, attrs):
        attrs = super().validate(attrs)
        if not self.user.is_active:
            return attrs
        raise exceptions.PermissionDenied(self.error_messages["stale_token"])


class UserUpdateSerializer(serializers.ModelSerializer):
    avatar_image = serializers.ImageField(required=False)

    class Meta:
        model = User
        fields = ('pk', 'phone_number', 'username', 'first_name', 'last_name', 'password', 'is_chef', 'avatar_image')
        depth = 1

    def validate(self, attrs):
        data = attrs.copy()
        password = data.pop("password", None)
        user = self.context["request"].user or self.user

        if password:
            try:
                validate_password(password, user)
            except django_exceptions.ValidationError as e:
                serializer_error = serializers.as_serializer_error(e)
                raise serializers.ValidationError({"password": serializer_error["non_field_errors"]})
            user.set_password(password)
            user.save(update_fields={"password"})

        return data


class PasswordResetVerifyCodeSerializer(UidAndOtpSerializer):
    default_error_messages = {
        "stale_token": "Stale OTP code for given user"
    }

    def validate(self, attrs):
        attrs = super().validate(attrs)
        return attrs


class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(style={"input_type": "password"}, write_only=True)

    default_error_messages = {
        "cannot_create_user": settings.CONSTANTS.messages.CANNOT_CREATE_USER_ERROR
    }

    class Meta:
        model = User
        fields = ('pk', 'phone_number', 'username', 'password', 'is_chef')

    def validate(self, attrs):
        data = attrs.copy()

        user = User(**attrs)
        password = attrs.get("password")

        try:
            validate_password(password, user)
        except django_exceptions.ValidationError as e:
            serializer_error = serializers.as_serializer_error(e)
            raise serializers.ValidationError({
                "password": serializer_error["non_field_errors"]
            })

        return data

    def create(self, validated_data):
        try:
            user = self.perform_create(validated_data)
        except IntegrityError:
            self.fail("cannot_create_user")

        return user

    def perform_create(self, validated_data):
        with transaction.atomic():
            user = User.objects.create_user(**validated_data)

            def random_with_N_digits(n):
                range_start = 10 ** (n - 1)
                range_end = (10 ** n) - 1
                return randint(range_start, range_end)

            otp = random_with_N_digits(6)
            user.otp = otp
            user.is_active = False
            user.save(update_fields=["is_active", "otp"])
        return user


class RecipeIngredientsSerializer(serializers.ModelSerializer):
    # ingredient = serializers.SerializerMethodField()
    #
    # def get_ingredient(self, obj):
    #     return obj.ingredient.name

    class Meta:
        model = RecipeIngredients
        fields = ('ingredient', 'unit')


class RecipePreparationSerializer(serializers.ModelSerializer):

    class Meta:
        model = RecipePreparation
        fields = ('detail', )


class RecipeCookSerializer(serializers.ModelSerializer):

    class Meta:
        model = RecipeCook
        fields = ('detail', )


class RecipeVideoSerializer(serializers.ModelSerializer):

    class Meta:
        model = RecipeVideo
        fields = ('video', )


class RecipeSerializer(serializers.ModelSerializer):
    recipe_ingredients = RecipeIngredientsSerializer(many=True)
    preparations = RecipePreparationSerializer(many=True)
    # cook_steps = RecipeCookSerializer(many=True)
    videos = RecipeVideoSerializer(many=True)
    chef = UserSerializer()
    is_liked = serializers.SerializerMethodField()

    def get_is_liked(self, obj):
        request = self.context.get('request', None)
        if request.user:
            return obj.likes.filter(pk=request.user.pk).exists()
        return False

    class Meta:
        model = Recipe
        fields = ('pk', 'chef', 'name', 'category', 'description', 'serving', 'image', 'viewed',
                  'prep_time', 'cooking_time', 'approved', 'unbox', 'recipe_ingredients', 'preparations',
                  'videos', 'learn_more_title', 'learn_more_desc', 'is_this_week', 'likes', 'is_liked')


class SimpleRecipeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Recipe
        fields = ('pk', )


class UnboxingSerializer(serializers.ModelSerializer):
    chef = UserSerializer()

    class Meta:
        model = Unboxing
        fields = ('pk', 'chef', 'video', 'timestamp', 'is_current')

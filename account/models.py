import uuid
from django.db import models
from django.contrib.auth.models import User as AuthUser, Permission, AbstractUser as DjangoAbstractUser
from django.contrib.auth.base_user import AbstractBaseUser as DjangoAbstractBaseUser, BaseUserManager as DjangoBaseUserManager
from django.contrib.auth.validators import UnicodeUsernameValidator, ASCIIUsernameValidator
from phonenumber_field.modelfields import PhoneNumberField
from django.conf import settings
from django.urls import reverse
from django.utils import timezone
from random import randint, choice
from string import ascii_letters, digits
from core.utils import ensure_path_exists, make_thumbnail
from core.overrides.storage_backend import PrivateMediaStorage


# Create your models here.

class UserManager(DjangoBaseUserManager):
    use_in_migrations = True

    def _create_user(self, password, phone_number, username=None, **extra_fields):
        if not phone_number:
            raise ValueError("Users must have a valid phone number")

        username = self.model.normalize_username(username)
        user = self.model(username=username, phone_number=phone_number, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, password, phone_number, username=None, **extra_fields):
        extra_fields.setdefault('is_staff', False)
        extra_fields.setdefault('is_superuser', False)
        return self._create_user(password, phone_number, username, **extra_fields)

    def create_superuser(self, password, phone_number, username=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True')

        return self._create_user(password, phone_number, username, **extra_fields)


def avatar_path(instance, filename):
    path = settings.GENERAL_UPLOAD_PATH.format(phone_number=instance.phone_number, path='/avatar/')
    ensure_path_exists(path)
    import os
    return os.path.join(path, filename)


class AbstractUser(DjangoAbstractUser):
    BOOL_CHOICES = ((True, 'Active'), (False, 'Inactive'))

    username_validator = UnicodeUsernameValidator()

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone_number = PhoneNumberField(unique=True, null=True, blank=True, default=None)

    username = models.CharField('username', max_length=100, null=True, blank=True, default=None)

    otp = models.PositiveIntegerField(default=202104)
    is_active = models.BooleanField('status', choices=BOOL_CHOICES, default=True)
    phone_verified = models.BooleanField('phone_verified', default=False)
    avatar_image = models.ImageField('avatar', upload_to=avatar_path, blank=True, null=True, default=None,
                                     storage=PrivateMediaStorage())
    avatar_thumbnail = models.ImageField('thumbnail', blank=True, null=True, default=None)

    created = models.DateTimeField(auto_now_add=True)

    objects = UserManager()
    PHONE_NUMBER_FIELD = 'phone_number'
    USERNAME_FIELD = getattr(settings, "AUTH_SIGN_IN_BY", "username")

    REQUIRED_FIELDS = []
    if getattr(settings, 'AUTH_SIGN_IN_BY', 'username') != 'phone_number':
        REQUIRED_FIELDS.append(PHONE_NUMBER_FIELD)

    class Meta:
        verbose_name = 'user'
        verbose_name_plural = 'users'
        abstract = True


class User(AbstractUser):
    is_chef = models.BooleanField(default=False)
    forgot_password = models.BooleanField(default=False)

    def __init__(self, *args, **kwargs):
        super(User, self).__init__(*args, **kwargs)

    @property
    def activation_link(self):
        return ''

    @property
    def user_pic_url(self):
        if self.avatar_image:
            return self.avatar_image.url
        return "{}{}".format(settings.STATIC_URL, 'core/img/user.jpg')

    @property
    def get_avatar_thumbnail(self):
        if self.avatar_image:
            try:
                return self.avatar_thumbnail.url
            except ValueError:
                if not make_thumbnail(self.avatar_thumbnail, self.avatar_image, settings.THUMBNAIL_IMAGE_SIZE, 'thumb'):
                    return None
            return self.get_avatar_thumbnail
        else:
            return self.user_pic_url

    @property
    def fullname(self):
        return self.get_full_name()

    def generate_otp(self):
        def random_with_N_digits(n):
            range_start = 10 ** (n - 1)
            range_end = (10 ** n) - 1
            return randint(range_start, range_end)
        self.otp = random_with_N_digits(6)
        self.save(update_fields=["otp"])
        return self.otp

    def __str__(self):
        if self.first_name and self.last_name:
            return "{} {}".format(self.first_name, self.last_name)
        else:
            return "{}".format(self.phone_number)

    class Meta:
        abstract = False
        app_label = 'account'
        swappable = 'AUTH_USER_MODEL'
        db_table = 'account_user'

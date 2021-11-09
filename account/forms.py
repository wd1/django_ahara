from uuid import UUID
from django import forms
from django.conf import settings
from django.contrib.auth import get_user_model, password_validation, authenticate
from django.contrib.auth.forms import AuthenticationForm as AF, UserCreationForm, SetPasswordForm
from django.contrib.auth.tokens import default_token_generator
from django.core.exceptions import ValidationError
from django.utils.text import capfirst
from django.db.utils import ProgrammingError
from django.template import loader
from django.urls import reverse
from phonenumber_field.formfields import PhoneNumberField

UserModel = get_user_model()


class AuthenticationForm(forms.Form):

    def __init__(self, request=None, *args, **kwargs):
        """
        The 'request' parameter is set for custom auth use by subclasses.
        The form data comes in via the standard 'data' kwarg.
        """
        self.request = request
        self.user_cache = None
        super().__init__(*args, **kwargs)

        # Set the max length and label for the "username" field.
        self.username_field = UserModel._meta.get_field(UserModel.USERNAME_FIELD)
        username_max_length = self.username_field.max_length or 254
        self.fields['phone_number'].max_length = username_max_length
        self.fields['phone_number'].widget.attrs['maxlength'] = username_max_length
        if self.fields['phone_number'].label is None:
            self.fields['phone_number'].label = capfirst(self.username_field.verbose_name)

    def clean(self):
        phone_number = self.cleaned_data.get('phone_number')
        password = self.cleaned_data.get('password')

        if phone_number is not None and password:
            self.user_cache = authenticate(self.request, phone_number=phone_number, password=password)
            if self.user_cache is None:
                raise self.get_invalid_login_error()
            else:
                self.confirm_login_allowed(self.user_cache)

        return self.cleaned_data

    def confirm_login_allowed(self, user):
        """
        Controls whether the given User may log in. This is a policy setting,
        independent of end-user authentication. This default behavior is to
        allow login by active users, and reject login by inactive users.

        If the given user cannot log in, this method should raise a
        ``ValidationError``.

        If the given user may log in, this method should return None.
        """
        if not user.is_active:
            raise ValidationError(
                self.error_messages['inactive'],
                code='inactive',
            )

    def get_user(self):
        return self.user_cache

    def get_invalid_login_error(self):
        return ValidationError(
            self.error_messages['invalid_login'],
            code='invalid_login',
            params={'phone_number': self.username_field.verbose_name},
        )

    def confirm_login_allowed(self, user):
        if not user.is_active:
            raise forms.ValidationError('There was a problem with your login', code='invalid_login')


class LoginForm(AuthenticationForm):
    def __init__(self, request=None, *args, **kwargs):
        super(LoginForm, self).__init__(request=request, *args, **kwargs)

    phone_number = PhoneNumberField(label='Phone Number', max_length=254,
                                    widget=forms.TextInput(attrs={'class': 'form-control m-input',
                                                                  'placeholder': 'Phone Number',
                                                                  'autocomplete': 'off'}))
    password = forms.CharField(required=True, label="Password", max_length=20, widget=forms.PasswordInput(
        attrs={'class': 'form-control m-input m-login__form-input--last', 'name': 'password',
               'placeholder': 'Password'}))

    error_messages = {
        'invalid_login': (
            "Please enter a correct %(phone_number)s and password. Note that both "
            "fields may be case-sensitive."
        ),
        'inactive': (
            "This account is inactive."
        ),
        'invalid_permission': (
            "This account do not have access to Admin Panel"
        )
    }

    def confirm_login_allowed(self, user):
        super().confirm_login_allowed(user)
        # if not user.is_superuser and not user.is_chef:
        #     raise ValidationError(
        #         self.error_messages['invalid_permission'],
        #         code='invalid_login',
        #         params={'phone_number': self.username_field.verbose_name}
        #     )


class SignUpForm(UserCreationForm):
    first_name = forms.CharField(max_length=30, required=False, help_text='Optional.')
    last_name = forms.CharField(max_length=30, required=False, help_text='Optional.')
    phone_number = PhoneNumberField(label='Phone Number', max_length=254,
                                    widget=forms.TextInput(attrs={'class': 'form-control m-input',
                                                                  'placeholder': 'Phone Number',
                                                                  'autocomplete': 'off'}))

    class Meta:
        model = UserModel
        fields = ('first_name', 'last_name', 'phone_number', 'password1', 'password2', )


class ResetPasswordForm(SetPasswordForm):
    class Meta:
        model = UserModel
        fields = ('new_password1', 'new_password2')

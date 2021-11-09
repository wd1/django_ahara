from django.shortcuts import reverse
from django import forms
from django.forms import formset_factory, modelformset_factory
from django.forms.models import BaseModelFormSet
from django.conf import settings
from django.contrib.auth import password_validation
from django.contrib.auth.forms import UserCreationForm
from django.forms import models
from account.models import User
from .models import Recipe, RecipePreparation, RecipeIngredients, RecipeCook, RecipeVideo, Unboxing, Ingredient
from phonenumber_field.formfields import PhoneNumberField


class CleanerNonFormMsgFormset(BaseModelFormSet):

    def __init__(self, *args, **kwargs):
        super(CleanerNonFormMsgFormset, self).__init__(*args, **kwargs)
        self.extra_errors = []

    def full_clean(self):
        super(CleanerNonFormMsgFormset, self).full_clean()

        for error in self._non_form_errors.as_data():
            if error.code == 'too_many_forms':
                error.message = "Maximum of {} {} required".format(self.max_num, "{} is".format(self.form.Meta.model._meta.verbose_name) if self.max_num == 1 else "{} are".format(self.form.Meta.model._meta.verbose_name_plural))
            if error.code == 'too_few_forms':
                error.message = "Minimum of {} {} required".format(self.min_num, "{} is".format(self.form.Meta.model._meta.verbose_name) if self.min_num == 1 else "{} are".format(self.form.Meta.model._meta.verbose_name_plural))


class MinimumRequiredFormSet(BaseModelFormSet):
    """
    Inline formset that enforces a minimum number of non-deleted forms
    that are not empty
    """
    default_minimum_forms_message = "At least %s set%s of data is required"

    def __init__(self, *args, **kwargs):
        self.minimum_forms = kwargs.pop('minimum_forms', 0)
        minimum_forms_message = kwargs.pop('minimum_forms_message', None)
        if minimum_forms_message:
            self.minimum_forms_message = minimum_forms_message
        else:
            self.minimum_forms_message = \
                self.default_minimum_forms_message % (
                    self.minimum_forms,
                    '' if self.minimum_forms == 1 else 's'
                )

        super(MinimumRequiredFormSet, self).__init__(*args, **kwargs)

    def clean(self):
        non_deleted_forms = self.total_form_count()
        non_empty_forms = 0
        for i in range(0, self.total_form_count()):
            form = self.forms[i]
            if self.can_delete and self._should_delete_form(form):
                non_deleted_forms -= 1
            if not (form.instance.id is None and not form.has_changed()):
                non_empty_forms += 1
        if (
                non_deleted_forms < self.minimum_forms
                or non_empty_forms < self.minimum_forms
        ):
            self.forms[0].add_error('video', self.minimum_forms_message)
            raise forms.ValidationError(message=self.minimum_forms_message)


class RequiredFormSet(BaseModelFormSet):
    def __init__(self, *args, **kwargs):
        super(RequiredFormSet, self).__init__(*args, **kwargs)
        for form in self.forms:
            form.empty_permitted = False


class UserForm(UserCreationForm):
    phone_number = PhoneNumberField(label='Phone Number', max_length=254, region=settings.PHONENUMBER_DEFAULT_REGION,
                                    widget=forms.TextInput(attrs={'class': 'form-control m-input',
                                                                  'placeholder': 'Phone Number',
                                                                  'autocomplete': 'off'}))
    password1 = forms.CharField(
        label="Password",
        strip=False,
        widget=forms.PasswordInput(attrs={'autocomplete': 'off', 'placeholder': 'Enter password',
                                          'class': 'form-control form-control-user round-control'})
    )
    password2 = forms.CharField(
        label="Confirm Password",
        widget=forms.PasswordInput(attrs={'autocomplete': 'off', 'placeholder': 'Re-enter password',
                                          'class': 'form-control form-control-user round-control'}),
        strip=False,
        help_text="Enter the same password as before, for verification.",
    )

    def __init__(self, *args, **kwargs):
        super(UserForm, self).__init__(*args, **kwargs)
        self.fields['is_chef'].label = "Is Chef"

    class Meta:
        model = User
        fields = ('first_name', 'last_name', 'phone_number', 'password1', 'password2', 'avatar_image', 'is_chef')


class RecipeForm(forms.ModelForm):
    prep_time = forms.IntegerField(label='Prep Time (Min)')
    cooking_time = forms.IntegerField(label='Cooking Time (Min)')
    image = forms.ImageField(help_text='(bmp, gif, jpg, jpeg, ico, png)')

    def __init__(self, *args, **kwargs):
        super(RecipeForm, self).__init__(*args, **kwargs)
        self.fields['serving'].label = "Servings"

    class Meta:
        model = Recipe
        fields = ('name', 'category', 'description', 'serving',
                  'prep_time', 'cooking_time', 'approved', 'unbox', 'image', 'is_this_week')


class RecipePreparationForm(forms.ModelForm):
    detail = forms.CharField(widget=forms.Textarea(attrs={"rows": 3}))

    class Meta:
        model = RecipePreparation
        fields = ('detail', )


RecipePreparationFormSet = modelformset_factory(RecipePreparation, form=RecipePreparationForm)


class RecipeIngredientForm(forms.ModelForm):
    # ingredient = forms.ModelChoiceField(queryset=Ingredient.objects.all(),
    #                                     widget=autocomplete.ModelSelect2(
    #                                         url='core:ingredient_autocomplete',
    #                                         attrs={
    #                                             'data-placeholder': 'Autocomplete ...',
    #                                             'data-minimum-input-length': 3,
    #                                             'data-html': True
    #                                         }
    #                                     ))

    def __init__(self, *args, **kwargs):
        super(RecipeIngredientForm, self).__init__(*args, **kwargs)
        self.fields['ingredient'].widget.attrs = {'data-type': 'ingredient',
                                                  'class': 'ingredient-input',
                                                  'autocomplete': 'off'
                                                  }

    class Meta:
        model = RecipeIngredients
        fields = ('ingredient', 'unit')


RecipeIngredientFormSet = modelformset_factory(RecipeIngredients, form=RecipeIngredientForm)


class RecipeCookForm(forms.ModelForm):
    detail = forms.CharField(widget=forms.Textarea(attrs={"rows": 3}))

    class Meta:
        model = RecipeCook
        fields = ('detail', )


RecipeCookFormSet = modelformset_factory(RecipeCook, form=RecipeCookForm)


class RecipeLearnMoreForm(forms.ModelForm):
    learn_more_title = forms.CharField(label='Title', required=False)
    learn_more_desc = forms.CharField(label='Description', widget=forms.Textarea(attrs={'rows': 3}), required=False)

    class Meta:
        model = Recipe
        fields = ('learn_more_title', 'learn_more_desc')


class RecipeVideoForm(forms.ModelForm):
    video = forms.FileField(help_text='(mp4, mov, wmv, avi, mkv)',
                            widget=forms.FileInput(attrs={'accept': 'video/*'}),
                            required=True)

    def clean(self):
        cleaned_data = self.cleaned_data
        file = cleaned_data.get("video", None)

        if file is None:
            raise forms.ValidationError('Please select file first ')

        try:
            if not file.content_type in settings.UPLOAD_VIDEO_TYPE:
                raise forms.ValidationError('This is not supported format')
        except AttributeError:
            return cleaned_data

        return cleaned_data

    class Meta:
        model = RecipeVideo
        fields = ('video', )


RecipeVideoFormSet = modelformset_factory(RecipeVideo, form=RecipeVideoForm, formset=RequiredFormSet, extra=0, min_num=1)


class UnboxingForm(forms.ModelForm):
    is_current = forms.BooleanField(label="This week video", required=False)
    video = forms.FileField(help_text='(mp4, mov, wmv, avi, mkv)',
                            widget=forms.FileInput(attrs={'accept': 'video/*'}))

    def clean(self):
        cleaned_data = self.cleaned_data
        file = cleaned_data.get("video")

        if file is None:
            raise forms.ValidationError('Please select file first ')

        try:
            if not file.content_type in settings.UPLOAD_VIDEO_TYPE:
                raise forms.ValidationError('This is not supported format')
        except AttributeError:
            return cleaned_data

        return cleaned_data

    class Meta:
        model = Unboxing
        fields = ('video', 'is_current')

from django.shortcuts import render, reverse, redirect, HttpResponse
from django.contrib.sites.shortcuts import get_current_site
from django.contrib import messages
from django.conf import settings
from django.contrib.auth import get_user_model, login as auth_login, authenticate
from django.contrib.auth.views import LoginView as LV, LogoutView as LOV
from django.contrib.auth.tokens import default_token_generator
from django.http import HttpResponseRedirect
from django.db import transaction, IntegrityError
from .forms import LoginForm, SignUpForm, ResetPasswordForm
from core.helper import send_sms
import base64


# Create your views here.
UserModel = get_user_model()


class LoginView(LV):
    authentication_form = LoginForm
    template_name = 'account/login.html'

    def form_valid(self, form):
        if not self.request.POST.get('remember_me', False):
            self.request.session.set_expiry(0)

        user = form.get_user()
        if user.phone_verified:
            auth_login(self.request, user)
            return HttpResponseRedirect(self.get_success_url())
        otp = user.generate_otp()
        send_sms(str(user.phone_number), 'Your Ahara activation code is: {}'.format(otp))
        return redirect('account:verify_code', user.pk)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        current_site = get_current_site(self.request)
        context.update({
            self.redirect_field_name: self.get_redirect_url(),
            'site': current_site,
            'site_name': current_site.name,
            **(self.extra_context or {})
        })
        return context

    def get_success_url(self):
        return super(LoginView, self).get_success_url()

    def get_redirect_url(self):
        return super(LoginView, self).get_redirect_url()


def login(request):
    if request.method == 'POST':
        form = LoginForm(data=request.POST)
        print('111111111111111')
        if form.is_valid():
            print('222222222222222')
            if not request.POST.get('remember_me', False):
                request.session.set_expiry(0)

            print('33333333333333')
            user = form.get_user()
            if user.phone_verified:
                auth_login(request, user)
                return redirect('core:home')
            print('444444444444444444')
            otp = user.generate_otp()
            send_sms(str(user.phone_number), 'Your Ahara activation code is: {}'.format(otp))
            return redirect('account:verify_code', user.pk)
    else:
        form = LoginForm()

    return render(request, 'account/login.html', context={'form': form})


class LogoutView(LOV):
    next_page = settings.LOGIN_REDIRECT_URL


def signup(request):
    if request.method == 'POST':
        form = SignUpForm(request.POST)
        if form.is_valid():
            form.save()
            phone_number = form.cleaned_data.get('phone_number')
            raw_password = form.cleaned_data.get('password1')

            user = authenticate(username=phone_number, password=raw_password)
            otp = user.generate_otp()
            send_sms(phone_number, 'Your Ahara activation code is: {}'.format(otp))
            # auth_login(request, user)
            return redirect('account:verify_code', user.pk)
    else:
        form = SignUpForm()
    return render(request, 'account/signup.html', context={'form': form})


def verify_code(request, pk):
    user = UserModel.objects.get(pk=pk)
    err_invalid = None
    if request.method == 'POST':
        code = request.POST.get('code', None)
        if str(user.otp) == code:
            user.phone_verified = True
            user.save()
            if user.forgot_password:
                return redirect('account:reset-password', user.pk)
            auth_login(request, user)
            return redirect('core:home')
        err_invalid = "Invalid Code"
    return render(request, 'account/verify-code.html', context={"err_invalid": err_invalid})


def forgot_password(request):
    if request.method == 'POST':
        username = request.POST.get('username', None)
        user = UserModel.objects.filter(phone_number=username).first()
        if not user:
            return render(request, 'account/forgot-password.html', {'err_message': "User doesn't exist"})
        user.forgot_password = True
        user.save()
        otp = user.generate_otp()
        send_sms(str(user.phone_number), 'Your Ahara verification code is: {}'.format(otp))
        # message = "{}".format(otp)
        # message_bytes = message.encode('ascii')
        # base64_bytes = base64.b64encode(message_bytes)
        # base64_message = base64_bytes.decode('ascii')
        return redirect('account:verify_code', user.pk)
    return render(request, 'account/forgot-password.html', context={"err_message": None})


def reset_password(request, pk):
    user = UserModel.objects.get(pk=pk)
    if request.method == 'POST':
        form = ResetPasswordForm(user=user, data=request.POST)
        if form.is_valid():
            form.save()
            user.forgot_password = False
            user.save()
            messages.success(request, 'Password changed successfully')
            return redirect('account:login')
    else:
        form = ResetPasswordForm(user=user)
    return render(request, 'account/reset-password.html', context={'form': form})


def test_sms(request):
    send_sms("+12194013558", "Test once")
    return HttpResponse('OK')

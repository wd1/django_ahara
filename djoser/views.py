from django.contrib.auth import get_user_model, update_session_auth_hash
from django.contrib.auth.tokens import default_token_generator

from django.utils.timezone import now
from rest_framework import generics, status, views, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import NotFound
from rest_framework.response import Response

from djoser import signals, utils
from djoser.compat import get_user_email
from djoser.conf import settings
from core.helper import send_sms

User = get_user_model()


class TokenCreateView(utils.ActionViewMixin, generics.GenericAPIView):
    """
    Use this endpoint to obtain user authentication token.
    """

    serializer_class = settings.SERIALIZERS.token_create
    permission_classes = settings.PERMISSIONS.token_create

    def _action(self, serializer):
        token = utils.login_user(self.request, serializer.user)
        token_serializer_class = settings.SERIALIZERS.token
        return Response(
            data=token_serializer_class(token).data, status=status.HTTP_200_OK
        )


class TokenDestroyView(views.APIView):
    """
    Use this endpoint to logout user (remove user authentication token).
    """

    permission_classes = settings.PERMISSIONS.token_destroy

    def post(self, request):
        utils.logout_user(request)
        return Response(status=status.HTTP_204_NO_CONTENT)


class UserViewSet(viewsets.ModelViewSet):
    serializer_class = settings.SERIALIZERS.user
    queryset = User.objects.all()
    permission_classes = settings.PERMISSIONS.user
    token_generator = default_token_generator
    lookup_field = settings.USER_ID_FIELD

    def permission_denied(self, request, message=None):
        if (
            settings.HIDE_USERS
            and request.user.is_authenticated
            and self.action in ["update", "partial_update", "list", "retrieve"]
        ):
            raise NotFound()
        super().permission_denied(request, message=message)

    def get_queryset(self):
        user = self.request.user
        queryset = super().get_queryset()
        if settings.HIDE_USERS and self.action == "list" and not user.is_staff:
            queryset = queryset.filter(pk=user.pk)
        return queryset

    def get_permissions(self):
        if self.action == "create":
            self.permission_classes = settings.PERMISSIONS.user_create
        elif self.action == "activation":
            self.permission_classes = settings.PERMISSIONS.activation
        elif self.action == "resend_activation":
            self.permission_classes = settings.PERMISSIONS.password_reset
        elif self.action == "list":
            self.permission_classes = settings.PERMISSIONS.user_list
        elif self.action == "reset_password":
            self.permission_classes = settings.PERMISSIONS.password_reset
        elif self.action == "reset_password_confirm":
            self.permission_classes = settings.PERMISSIONS.password_reset_confirm
        elif self.action == "reset_password_verify_code":
            self.permission_classes = settings.PERMISSIONS.password_reset
        elif self.action == "set_password":
            self.permission_classes = settings.PERMISSIONS.set_password
        elif self.action == "set_username":
            self.permission_classes = settings.PERMISSIONS.set_username
        elif self.action == "reset_username":
            self.permission_classes = settings.PERMISSIONS.username_reset
        elif self.action == "reset_username_confirm":
            self.permission_classes = settings.PERMISSIONS.username_reset_confirm
        elif self.action == "destroy" or (
            self.action == "me" and self.request and self.request.method == "DELETE"
        ):
            self.permission_classes = settings.PERMISSIONS.user_delete
        return super().get_permissions()

    def get_serializer_class(self):
        if self.action == "create":
            if settings.USER_CREATE_PASSWORD_RETYPE:
                return settings.SERIALIZERS.user_create_password_retype
            return settings.SERIALIZERS.user_create
        elif self.action == "destroy" or (
            self.action == "me" and self.request and self.request.method == "DELETE"
        ):
            return settings.SERIALIZERS.user_delete
        elif self.action == "activation":
            return settings.SERIALIZERS.activation
        elif self.action == "resend_activation":
            return settings.SERIALIZERS.password_reset
        elif self.action == "reset_password":
            return settings.SERIALIZERS.password_reset
        elif self.action == "reset_password_verify_code":
            return settings.SERIALIZERS.reset_password_verify_code
        elif self.action == "reset_password_confirm":
            if settings.PASSWORD_RESET_CONFIRM_RETYPE:
                return settings.SERIALIZERS.password_reset_confirm_retype
            return settings.SERIALIZERS.password_reset_confirm
        elif self.action == "set_password":
            if settings.SET_PASSWORD_RETYPE:
                return settings.SERIALIZERS.set_password_retype
            return settings.SERIALIZERS.set_password
        elif self.action == "set_username":
            if settings.SET_USERNAME_RETYPE:
                return settings.SERIALIZERS.set_username_retype
            return settings.SERIALIZERS.set_username
        elif self.action == "reset_username":
            return settings.SERIALIZERS.username_reset
        elif self.action == "reset_username_confirm":
            if settings.USERNAME_RESET_CONFIRM_RETYPE:
                return settings.SERIALIZERS.username_reset_confirm_retype
            return settings.SERIALIZERS.username_reset_confirm
        elif self.action == "me":
            return settings.SERIALIZERS.current_user
        elif self.action == 'get_by_email':
            return settings.SERIALIZERS.current_user

        return self.serializer_class

    def get_instance(self):
        return self.request.user

    def perform_create(self, serializer):
        user = serializer.save()
        signals.user_registered.send(
            sender=self.__class__, user=user, request=self.request
        )

        context = {"user": user}
        to = [get_user_email(user)]
        if settings.SEND_ACTIVATION_EMAIL:
            settings.EMAIL.activation(self.request, context).send(to)
        elif settings.SEND_CONFIRMATION_EMAIL:
            settings.EMAIL.confirmation(self.request, context).send(to)

    def perform_update(self, serializer):
        super().perform_update(serializer)
        # user = serializer.instance
        # should we send activation email after update?
        # if settings.SEND_ACTIVATION_EMAIL:
        #     context = {"user": user}
        #     to = [get_user_email(user)]
        #     settings.EMAIL.activation(self.request, context).send(to)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data)
        serializer.is_valid(raise_exception=True)

        if instance == request.user:
            utils.logout_user(self.request)
        self.perform_destroy(instance)
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(["get", "put", "patch", "delete"], detail=False)
    def me(self, request, *args, **kwargs):
        self.get_object = self.get_instance
        if request.method == "GET":
            return self.retrieve(request, *args, **kwargs)
        elif request.method == "PUT":
            return self.update(request, *args, **kwargs)
        elif request.method == "PATCH":
            return self.partial_update(request, *args, **kwargs)
        elif request.method == "DELETE":
            return self.destroy(request, *args, **kwargs)

    @action(["post"], detail=False)
    def activation(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.user
        user.is_active = True
        user.save()

        signals.user_activated.send(
            sender=self.__class__, user=user, request=self.request
        )

        # if settings.SEND_CONFIRMATION_EMAIL:
        #     context = {"user": user}
        #     to = [get_user_email(user)]
        #     settings.EMAIL.confirmation(self.request, context).send(to)

        if settings.LOGIN_AFTER_ACTIVATION:
            token = utils.login_user(self.request, user)
            token_serializer_class = settings.SERIALIZERS.token
            data = token_serializer_class(token).data
        else:
            data = {}
        return Response(data=data, status=status.HTTP_200_OK)

    @action(["post"], detail=False)
    def resend_activation(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.get_user(is_active=False)

        if not settings.SEND_ACTIVATION_EMAIL or not user:
            return Response(status=status.HTTP_400_BAD_REQUEST)

        otp = user.generate_otp()
        send_sms(str(user.phone_number), 'Your Ahara activation code is: {}'.format(otp))
        # context = {"user": user}
        # to = [get_user_email(user)]
        # settings.EMAIL.activation(self.request, context).send(to)

        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(["post"], detail=False)
    def set_password(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        self.request.user.set_password(serializer.data["new_password"])
        self.request.user.save()

        if settings.PASSWORD_CHANGED_EMAIL_CONFIRMATION:
            otp = self.request.user.generate_otp()
            send_sms(str(self.request.user.phone_number), 'Your Ahara activation code is: {}'.format(otp))
            # context = {"user": self.request.user}
            # to = [get_user_email(self.request.user)]
            # settings.EMAIL.password_changed_confirmation(self.request, context).send(to)

        if settings.LOGOUT_ON_PASSWORD_CHANGE:
            utils.logout_user(self.request)
        elif settings.CREATE_SESSION_ON_LOGIN:
            update_session_auth_hash(self.request, self.request.user)
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(["post"], detail=False)
    def reset_password(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.get_user()

        if user:
            otp = user.generate_otp()
            send_sms(str(user.phone_number), 'Your Ahara activation code is: {}'.format(otp))
            # context = {"user": user}
            # to = [get_user_email(user)]
            # settings.EMAIL.password_reset(self.request, context).send(to)
        else:
            return Response(status=status.HTTP_404_NOT_FOUND, data={'message': "User not found"})

        return Response(status=status.HTTP_200_OK, data={'message': 'Send verification code'})

    @action(["post"], detail=False)
    def reset_password_verify_code(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.user

        signals.user_activated.send(
            sender=self.__class__, user=user, request=self.request
        )

        token = default_token_generator.make_token(user)
        uid = utils.encode_uid(user.pk)
        return Response(data={'token': token, 'uid': uid}, status=status.HTTP_200_OK)

    @action(["post"], detail=False)
    def reset_password_confirm(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        serializer.user.set_password(serializer.data["new_password"])
        if hasattr(serializer.user, "last_login"):
            serializer.user.last_login = now()
        serializer.user.save()

        if settings.PASSWORD_CHANGED_EMAIL_CONFIRMATION:
            context = {"user": serializer.user}
            to = [get_user_email(serializer.user)]
            settings.EMAIL.password_changed_confirmation(self.request, context).send(to)
        return Response(status=status.HTTP_200_OK, data={"message": "Succeed"})

    @action(["post"], detail=False, url_path="set_{}".format(User.USERNAME_FIELD))
    def set_username(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = self.request.user
        new_username = serializer.data["new_" + User.USERNAME_FIELD]

        setattr(user, User.USERNAME_FIELD, new_username)
        user.save()
        if settings.USERNAME_CHANGED_EMAIL_CONFIRMATION:
            context = {"user": user}
            to = [get_user_email(user)]
            settings.EMAIL.username_changed_confirmation(self.request, context).send(to)
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(["post"], detail=False, url_path="reset_{}".format(User.USERNAME_FIELD))
    def reset_username(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.get_user()

        if user:
            context = {"user": user}
            to = [get_user_email(user)]
            settings.EMAIL.username_reset(self.request, context).send(to)

        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(
        ["post"], detail=False, url_path="reset_{}_confirm".format(User.USERNAME_FIELD)
    )
    def reset_username_confirm(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        new_username = serializer.data["new_" + User.USERNAME_FIELD]

        setattr(serializer.user, User.USERNAME_FIELD, new_username)
        if hasattr(serializer.user, "last_login"):
            serializer.user.last_login = now()
        serializer.user.save()

        if settings.USERNAME_CHANGED_EMAIL_CONFIRMATION:
            context = {"user": serializer.user}
            to = [get_user_email(serializer.user)]
            settings.EMAIL.username_changed_confirmation(self.request, context).send(to)
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(["get"], detail=False)
    def generate_master_id(self, request):
        queryset = User.objects.filter(trainer_role=User.MASTER)
        if request.user.master:
            queryset = queryset.exclude(pk=request.user.master.pk)
        master = queryset.order_by("?").first()
        if not master:
            return Response(status=status.HTTP_404_NOT_FOUND, data={"error": "There isn't any master trainer"})
        return Response(status=status.HTTP_200_OK, data={'master_id': master.master_trainer_id})

    @action(["get"], detail=False, url_path='get-by-email')
    def get_by_email(self, request):
        pk = request.GET.get('pk', None)
        user = User.objects.filter(pk=pk).first()
        if not user:
            raise NotFound()
        serializer = self.get_serializer(user)
        return Response(status=status.HTTP_200_OK, data=serializer.data)

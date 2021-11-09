from djoser.conf import settings

__all__ = ["settings"]


def get_user_email(user):
    email_field_name = get_user_email_field_name(user)
    return getattr(user, email_field_name, None)


def get_user_email_field_name(user):
    return user.get_email_field_name()


def get_user_phone(user):
    phone_filed_name = get_user_phone_field_name(user)
    return getattr(user, phone_filed_name, None)


def get_user_phone_field_name(user):
    return 'phone_number'

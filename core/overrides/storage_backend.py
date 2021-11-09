from django.conf import settings
from storages.backends.s3boto3 import S3Boto3Storage
from storages.utils import safe_join


class PrivateMediaStorage(S3Boto3Storage):
    if not settings.USE_LOCAL_MEDIA:
        location = settings.AWS_PRIVATE_MEDIA_LOCATION
    default_acl = 'private'
    file_overwrite = False
    custom_domain = False

    def path(self, name):
        return None


class PublicMediaStorage(S3Boto3Storage):
    if not settings.USE_LOCAL_MEDIA:
        location = settings.AWS_PUBLIC_MEDIA_LOCATION
    file_overwrite = False

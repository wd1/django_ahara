import logging
from django.conf import settings
from django.core.files.base import ContentFile
from PIL import Image
import os
from io import BytesIO
import copy
from django.utils.safestring import mark_safe

logger = logging.getLogger(__name__)


def ensure_path_exists(path):
    if settings.DEFAULT_FILE_STORAGE == 'core.overrides.storage_backend.PrivateMediaStorage':
        os.umask(0)
        att_path = os.path.join(settings.MEDIA_ROOT, path)
        if not os.path.exists(att_path):
            os.makedirs(att_path, 0o777)


def make_thumbnail(thumb_field, image_field, size, name_suffix, sep='_'):
    """
    Makes thumbnail/icon image from source image field & thumbnail/icon field
    @example
        make_thumbnail(self.thumbnail, self.image, (200, 200), 'thumb')
    """
    dst_path, dst_ext = os.path.splitext(image_field.name)
    dst_ext = dst_ext.lower()

    dst_fname = dst_path.split('_')[0] + sep + name_suffix + dst_ext

    if dst_ext in ['.jpg', '.jpeg']:
        file_type = 'JPEG'
    elif dst_ext == '.gif':
        file_type = 'GIF'
    elif dst_ext == '.png':
        file_type = 'PNG'
    else:
        raise RuntimeError('unrecognized file type of "{}"'.format(dst_ext))

    try:
        image = Image.open(image_field)
        image.thumbnail(size, Image.ANTIALIAS)
        dst_bytes = BytesIO()
        image.save(dst_bytes, file_type)
        dst_bytes.seek(0)

        thumb_field.save(dst_fname, ContentFile(dst_bytes.read()), save=False)
        dst_bytes.close()
        return True
    except FileNotFoundError as err:
        return False

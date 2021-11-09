import os
import sys
import string
from shlex import shlex
from configparser import ConfigParser

text_type = str


class UndefinedValueError(Exception):
    pass


class Undefined(object):
    pass


undefined = Undefined()


class Config(object):
    _BOOLEANS = {'1': True, 'yes': True, 'true': True, 'on': True,
                 '0': False, 'no': False, 'false': False, 'off': False, '': False}

    def __init__(self, repository):
        self.repository = repository

    def _cast_boolean(self, value):
        value = str(value)
        if value.lower() not in self._BOOLEANS:
            raise ValueError('Not a boolean: %s' % value)

        return self._BOOLEANS[value.lower()]

    @staticmethod
    def _cast_do_nothing(value):
        return value

    def get(self, option, default=undefined, cast=undefined):
        if option in os.environ:
            value = os.environ[option]
        elif option in self.repository:
            value = self.repository[option]
        else:
            if isinstance(default, Undefined):
                raise UndefinedValueError('{} not found, Declare it as envvar or define a default value.'.format(option))

            value = default

        if isinstance(cast, Undefined):
            cast = self._cast_do_nothing
        elif cast is bool:
            cast = self._cast_boolean

        return cast(value)

    def __call__(self, *args, **kwargs):
        return self.get(*args, **kwargs)


class RepositoryEmpty(object):
    def __init__(self, source=''):
        pass

    def __contains__(self, item):
        return False

    def __getitem__(self, item):
        return None


class RepositoryIni(RepositoryEmpty):
    SECTION = 'settings'

    def __init__(self, source):
        self.parser = ConfigParser()
        with open(source) as file_:
            self.parser.readfp(file_)

    def __contains__(self, item):
        return (item in os.environ or self.parser.has_option(self.SECTION, item))

    def __getitem__(self, item):
        return self.parser.get(self.SECTION, item)


class RepositoryEnv(RepositoryEmpty):
    def __init__(self, source):
        self.data = {}

        with open(source) as file_:
            for line in file_:
                line = line.strip()
                if not line or line.startswith('#') or '=' not in line:
                    continue
                k, v = line.split('=', 1)
                k = k.strip()
                v = v.strip().strip('\'"')
                self.data[k] = v

    def __contains__(self, item):
        return item in os.environ or item in self.data

    def __getitem__(self, item):
        return self.data[item]


class AutoConfig(object):
    SUPPORTED = {
        'settings.ini': RepositoryIni,
        '.env': RepositoryEnv
    }

    def __init__(self, search_path=None):
        self.search_path = search_path
        self.config = None

    def _find_file(self, path):
        for configfile in self.SUPPORTED:
            filename = os.path.join(path, configfile)
            if os.path.isfile(filename):
                return filename

        parent = os.path.dirname(path)
        if parent and parent != os.path.sep:
            return self._find_file(parent)

        return ''

    def _load(self, path):
        try:
            filename = self._find_file(os.path.abspath(path))
        except Exception:
            filename = ''
        Repository = self.SUPPORTED.get(os.path.basename(filename), RepositoryEmpty)

        self.config = Config(Repository(filename))

    def _caller_path(self):
        frame = sys._getframe()
        path = os.path.dirname(frame.f_back.f_back.f_code.co_filename)
        return path

    def __call__(self, *args, **kwargs):
        if not self.config:
            self._load(self.search_path or self._caller_path())

        return self.config(*args, **kwargs)


config = AutoConfig()

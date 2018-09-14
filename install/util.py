import os


def home_dir():
    return os.path.expanduser('~')


def project_dir():
    return os.path.dirname(os.path.dirname(__file__))

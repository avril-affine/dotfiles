import os
import subprocess
import sys


def home_dir() -> str:
    return os.path.expanduser('~')


def project_dir() -> str:
    return os.path.dirname(os.path.dirname(__file__))


def shell_command(command: str) -> bool:
    command = command.split()
    p = subprocess.Popen(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    p.wait()
    return p.returncode == 0


def shell_output(command: str) -> str:
    command = command.split()
    return subprocess.check_output(command).strip().decode('utf-8')


def is_osx() -> bool:
    return sys.platform == 'darwin'


def check_zsh_version(major=5, minor=6) -> bool:
    version_str = shell_output('zsh --version').split()[1]
    version_major = int(version_str.split('.')[0])
    version_minor = int(version_str.split('.')[1])
    return (version_major == major and version_minor >= minor) or (version_major > major)

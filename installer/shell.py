import os
from typing import Callable

from installer import util
from installer.base import Base


class Shell(Base):

    def __init__(self, name: str, install_check: Callable[[], bool]) -> None:
        assert os.path.exists(name)
        self.name = name
        self.install_check = install_check

    @property
    def is_installed(self) -> bool:
        return self.install_check()

    def install(self) -> None:
        if self.is_installed:
            return

        util.shell_command('bash {}'.format(self.name))

    def uninstall(self) -> None:
        print('Check {} for details on installation.')

import logging
import os
from typing import Callable

from installer import util
from installer.base import Base

logger = logging.getLogger(__name__)


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
            logger.info('Shell script %s already installed. Skipping...', self.name)
            return
        logger.info('Installing shell script %s...', self.name)

        ret = util.shell_command('bash {}'.format(self.name))
        if not ret:
            logger.error('Error installing shell script %s', self.name)

    def uninstall(self) -> None:
        print('Check {} for details on installation.')

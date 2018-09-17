import logging
from typing import List, Optional

from installer import util
from installer.base import Base

logger = logging.getLogger(__name__)


class BrewPackage(Base):

    def __init__(self, name: str, cask: Optional[str] = None) -> None:
        self.name = name
        self.cask = cask

    @property
    def is_installed(self) -> bool:
        if self.cask:
            return util.shell_command('brew cask info {}'.format(self.name))
        return util.shell_command('brew info {}'.format(self.name))

    def install(self) -> None:
        if self.is_installed:
            logger.info('Package %s already installed. Skipping...', self.name)
            return

        logger.info('Installing package %s...', self.name)

        if self.cask:
            util.shell_command('brew install {}'.format(self.cask))
            util.shell_command('brew cask install {}'.format(self.name))
        else:
            util.shell_command('brew install {}'.format(self.name))

    def uninstall(self) -> None:
        if self.is_installed:
            if self.cask:
                util.shell_command('brew cask uninstall {}'.format(self.name))
            else:
                util.shell_command('brew uninstall {}'.format(self.name))


class AptPackage(Base):

    def __init__(
        self,
        name: str,
        ppa: Optional[str] = None,
        alternatives: Optional[List[str]] = None) -> None:
        self.name = name
        self.ppa = ppa
        self.alternatives = alternatives or []

    @property
    def is_installed(self) -> bool:
        return util.shell_command('dpkg-query -W {}'.format(self.name))

    def install(self) -> None:
        if self.is_installed:
            return

        if self.ppa:
            util.shell_command('sudo add-apt-repository {}'.format(self.ppa))
            util.shell_command('sudo apt-get update')
        util.shell_command('sudo apt-get install -y {}'.format(self.name))
        for link, name, path, priority in self.alternatives:
            util.shell_command('sudo update-alternatives --install {} {} {} {}'.format(
                link, name, path, priority))
            util.shell_command('sudo update-alternatives --config {}'.format(name))

    def uninstall(self) -> None:
        if self.is_installed:
            util.shell_command('sudo apt-get remove --purge {}'.format(self.name))
            for _, name, _, _ in self.alternatives:
                util.shell_command('sudo update-alternatives --remove-all {}'.format(name))


class PipPackage(Base):

    def __init__(self, name: str) -> None:
        self.name = name

    @property
    def is_installed(self) -> bool:
        return util.shell_command('pip show {}'.format(self.name))

    def install(self) -> None:
        if self.is_installed:
            return

        util.shell_command('pip install {}'.format(self.name))

    def uninstall(self) -> None:
        if self.is_installed:
            util.shell_command('pip uninstall {}'.format(self.name))

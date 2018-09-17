import logging
import os
import re
import shutil

from installer import util
from installer.base import Base

logger = logging.getLogger(__name__)


class Symlink(Base):

    def __init__(self, name: str, do_backup: bool = True) -> None:
        assert name.endswith('.symlink')
        self.name = os.path.abspath(name)
        self.do_backup = do_backup

        # symlink file to home directory
        filename = os.path.basename(self.name)
        filename = '.' + re.sub(r'\.symlink$', '', filename)
        self.install_path = os.path.join(util.home_dir(), filename)

    @property
    def is_installed(self) -> bool:
        return (
            os.path.exists(self.install_path)
            and os.path.realpath(self.install_path) == self.name)

    def install(self) -> None:
        if self.is_installed:
            logger.info('Symlink %s already installed. Skipping...', self.name)
            return

        logger.info('Installing symlink %s...', self.name)

        if os.path.exists(self.install_path) and self.do_backup:
            self._backup()
            os.unlink(self.install_path)

        os.link(self.name, self.install_path)

    def uninstall(self) -> None:
        if self.is_installed:
            os.unlink(self.install_path)

    def _backup(self) -> None:
        backup_path = '{}.bak'.format(self.install_path)
        _backup_path = backup_path
        i = 1
        while True:
            if not os.path.exists(_backup_path):
                backup_path = _backup_path
                break
            _backup_path = '{}-{}'.format(backup_path, i)
            i += 1
        shutil.copy(
            self.install_path,
            backup_path)


class SourceSymlink(Symlink):

    def __init__(self, name: str) -> None:
        super().__init__(name, do_backup=False)
        assert self.install_path.endswith('.global')
        self.local_file = re.sub(r'\.global$', '', self.install_path)
        self.source_str = '[ -f {file} ] && source {file}\n'.format(file=self.install_path)

    @property
    def is_installed(self) -> bool:
        return self.source_str in self._read_local_file()

    def install(self) -> None:
        if self.is_installed:
            return

        with open(self.local_file, 'a') as f:
            f.write('\n' + self.source_str)

    def uninstall(self) -> None:
        if self.is_installed:
            contents = self._read_local_file()
            contents = re.sub(self.source_str, '', contents)
            with open(self.local_file, 'w') as f:
                f.write(contents)


    def _read_local_file(self) -> str:
        with open(self.local_file, 'r') as f:
            return f.read()

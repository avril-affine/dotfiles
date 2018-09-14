import os
import re
import shutil

import util
from base import Base


class Symlink(Base):

    def __init__(self, src_path: str, do_backup: bool = True) -> None:
        assert src_path.endswith('.symlink')
        self.src_path = os.path.abspath(src_path)
        self.do_backup = do_backup

        # symlink file to home directory
        filename = os.path.basename(self.src_path)
        filename = '.' + re.sub(r'\.symlink$', '', filename)
        self.install_path = os.path.join(util.home_dir(), filename)

    @property
    def is_installed(self) -> bool:
        return (
            os.path.exists(self.install_path)
            and os.path.realpath(self.install_path) == self.src_path)

    def install(self) -> None:
        if self.is_installed:
            return

        if os.path.exists(self.install_path) and self.do_backup:
            self._backup()
            os.unlink(self.install_path)

        os.link(self.src_path, self.install_path)

    def uninstall(self) -> None:
        if self.is_installed:
            os.unlink(self.install_path)

    def _backup(self) -> None:
        shutil.copyfile(
            self.install_path,
            '{}.bak'.format(self.install_path),
            follow_symlinks=False)


class SourceSymlink(Symlink):

    def __init__(self, src_path: str, append_line: str) -> None:
        super().__init__(src_path, do_backup=False)
        assert self.install_path.endswith('.global')
        self.append_line = append_line
        self.local_file = re.sub(r'\.global$', '', self.install_path)
        self.source_str = '\n[ -f {file} ] && source {file}\n'.format(file=self.install_path)

    @property
    def is_installed(self) -> bool:
        return self.source_str in self._read_local_file()

    def install(self) -> None:
        if self.is_installed:
            return

        with open(self.local_file, 'a') as f:
            f.write(self.source_str)

    def uninstall(self) -> None:
        contents = self._read_local_file()
        contents = re.sub(self.source_str, '', contents)
        with open(self.local_file, 'w') as f:
            f.write(contents)


    def _read_local_file(self) -> str:
        with open(self.local_file, 'r') as f:
            return f.read()

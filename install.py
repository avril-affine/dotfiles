#!/usr/bin/env python3

import argparse
import glob
import sys

from installer import util
from installer.package import AptPackage, BrewPackage, PipPackage
from installer.shell import Shell
from installer.symlink import Symlink, SourceSymlink

assert sys.version_info.major == 3 and sys.version_info.minor >= 5, \
    'Python version must be >= 3.5'


def main(args):
    installers = []

    # tmux
    installers += [
        Shell('installer/install-tmux.sh',
              install_check=lambda: (
                    util.shell_command('which tmux')
                    and util.shell_output('tmux -V') == 'tmux 2.6'
              )
        ),
    ]
    if util.is_osx():  # OSX packages
        installers += [
            Shell('installer/install-brew.sh',
                  install_check=lambda: util.shell_command('which brew')
            ),
            BrewPackage('xquartz', cask='caskroom/cask/brew-cask'),
            BrewPackage('reattach-to-user-namespace'),
            BrewPackage('neovim'),
            BrewPackage('automake'),
            BrewPackage('libevent'),
            BrewPackage('ripgrep'),
            BrewPackage('npm'),
        ]
    else:             # Ubuntu packages
        installers += [
            AptPackage('automake'),
            AptPackage('build-essential'),
            AptPackage('pkg-config'),
            AptPackage('libevent-dev'),
            AptPackage('libncurses5-dev'),
            AptPackage('software-properties-common'),
            AptPackage('neovim', ppa='ppa:neovim-ppa/stable',
                       alternatives=[
                           ['/usr/bin/vi', 'vi', '/usr/bin/nvim', '60'],
                           ['/usr/bin/vim', 'vim', '/usr/bin/nvim', '60'],
                           ['/usr/bin/editor', 'editor', '/usr/bin/nvim', '60'],
                       ]
            ),
            Shell('installer/install-ripgrep.sh',
                  install_check=lambda: util.shell_command('which rg')
            ),
            AptPackage('npm'),
        ]
    # pip
    installers += [
        PipPackage('neovim'),
        PipPackage('pylint'),
        PipPackage('pyls'),
        PipPackage('pyls-mypy'),
        PipPackage('pyls-isort'),
    ]
    # symlinks
    installers += [
        Symlink(f, args.backup)
        for f in glob.glob('**/*.symlink', recursive=True)
    ]
    # sourced symlinks
    installers += [
        SourceSymlink('zsh/zshrc.global.symlink'),
    ]

    fn_str = 'uninstall' if args.uninstall else 'install'

    for installer in installers:
        print(installer.name, installer.is_installed)
        # getattr(installer, fn_str)()


if __name__ == '__main__':
    parser = argparse.ArgumentParser('Dotfile installer.')
    parser.add_argument('--no-backup', dest='backup', action='store_false',
        help='If set, do not store backups of symlinked files.')
    parser.add_argument('--uninstall', action='store_true',
        help='Uninstall dotfiles.')
    args = parser.parse_args()
    main(args)

#!/usr/bin/env python3

import argparse
import logging
import glob
import os
import sys

from installer import util
from installer.package import AptPackage, BrewPackage, PipPackage
from installer.shell import Shell
from installer.symlink import Symlink, SourceSymlink

assert sys.version_info.major == 3 and sys.version_info.minor >= 5, \
    'Python version must be >= 3.5'


logger = logging.getLogger('installer')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter('[%(asctime)s] %(levelname)s %(message)s')
ch.setFormatter(formatter)
logger.addHandler(ch)


def main(args: argparse.Namespace):
    installers = []

    # zsh
    installers += [
        Shell('installer/install-zsh.sh',
              install_check=lambda: (
                    util.shell_command('which zsh')
                    and util.check_zsh_version()
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
        ]
    else:             # Ubuntu packages
        installers += [
            AptPackage('autotools-dev'),
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
        ]
    # tmux
    installers += [
        Shell('installer/install-tmux.sh',
              install_check=lambda: (
                    util.shell_command('which tmux')
                    and util.shell_output('tmux -V') == 'tmux 2.6'
              )
        ),
    ]
    # pip
    installers += [
        PipPackage('neovim'),
        PipPackage('pylint'),
        PipPackage('pyls'),
        PipPackage('pyls-mypy'),
        PipPackage('pyls-isort'),
    ]
    # oh-my-zsh
    installers += [
        Shell('installer/install-oh-my-zsh.sh',
              install_check=lambda: os.path.exists(os.path.join(util.home_dir(), '.oh-my-zsh'))
        ),
    ]
    # symlinks
    installers += [
        Symlink(sym_path, args.backup)
        for sym_path in glob.glob('**/*.symlink', recursive=True)
    ]
    # sourced symlinks
    installers += [
        SourceSymlink('zsh/zshrc.global.symlink'),
    ]
    # link nvim configs
    nvim_config_dir = os.path.join(util.home_dir(), '.config', 'nvim')
    nvim_link_dir = os.path.abspath('vim/vim.symlink')
    installers += [
        Shell('installer/install-nvim-links.sh',
              install_check=lambda: os.path.realpath(nvim_config_dir) == nvim_link_dir
        ),
    ]

    fn_str = 'uninstall' if args.uninstall else 'install'

    for installer in installers:
        getattr(installer, fn_str)()


if __name__ == '__main__':
    parser = argparse.ArgumentParser('Dotfile installer.')
    parser.add_argument('--no-backup', dest='backup', action='store_false',
        help='If set, do not store backups of symlinked files.')
    parser.add_argument('--uninstall', action='store_true',
        help='Uninstall dotfiles.')
    _args = parser.parse_args()
    main(_args)

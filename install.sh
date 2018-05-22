#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -e "$HOME/.tmux.conf" ]; then mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bkp"; fi
if [ -e "$HOME/.tmux.conf.local" ]; then mv "$HOME/.tmux.conf.local" "$HOME/.tmux.conf.local.bkp"; fi
if [ -e "$HOME/.vimrc" ]; then mv "$HOME/.vimrc" "$HOME/.vimrc.bkp"; fi
if [ -e "$HOME/.vim" ]; then mv "$HOME/.vim" "$HOME/.vim.bkp"; fi

ln -s "$DIR/tmux/tmux.conf.symlink" ~/.tmux.conf
ln -s "$DIR/tmux/tmux.conf.local.symlink" ~/.tmux.conf.local
ln -s "$DIR/vim/vimrc.symlink" ~/.vimrc
ln -s "$DIR/vim/vimfolder.symlink/" ~/.vim
ln -s "$DIR/bash/sshrc" ~/.ssh/rc

# Package dependencies / OS specific stuff
if uname -s | grep --quiet Linux; then
    # YouCompleteMe
    sudo apt-get install -y build-essential cmake
    sudo apt-get install -y python-dev python3-dev python-pip python3-pip

    # tmux
    sudo apt-get install -y automake
    sudo apt-get install -y build-essential
    sudo apt-get install -y pkg-config
    sudo apt-get install -y libevent-dev
    sudo apt-get install -y libncurses5-dev

    # Neovim
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:neovim-ppa/stable
    sudo apt-get update
    sudo apt-get install -y neovim
    sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
    sudo update-alternatives --config vi
    sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
    sudo update-alternatives --config vim
    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
    sudo update-alternatives --config editor

    # ag
    apt-get install silversearcher-ag
else
    # Install Homebrew
    which -s brew
    if [[ $? != 0 ]] ; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    # Install xquartz
    brew install caskroom/cask/brew-cask
    brew cask install xquartz

    # YouCompleteMe
    brew install cmake

    # vim
    brew install reattach-to-user-namespace

    # Neovim
    brew install neovim

    # tmux dependencies: aclocal and libevent
    brew install automake
    brew install libevent

    # ag
    brew install the_silver_searcher
fi

# Neovim
mkdir -p "$HOME/.config"
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim

pip install neovim

# Install plugins from Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# YouCompleteMe
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer
cd $OLDPWD

# .bashrc additions
cat "$DIR/bash/bashrc" >> "$HOME/.bashrc"
ln -s "$DIR/bash/aliases.sh" "$HOME/.aliases.sh"

# pylint
ln -s "$DIR/pylintrc" ~/.pylintrc

# .gitconfig
ln -s "$DIR/gitconfig" ~/.gitconfig

# tmux 2.6
git clone https://github.com/tmux/tmux.git ~/tmux
cd ~/tmux
git reset --hard 2c6af068d7f024b3c725777f78ee4feb1813bcf9
sh autogen.sh
if uname -s | grep --quiet Linux; then
    ./configure && make
else
    DIR="/usr/local/"
    ./configure CFLAGS="-I$DIR/include" LDFLAGS="-L$DIR/lib" && make
fi
cp ./tmux /usr/local/bin/tmux
cd $OLDPWD
rm -rf ~/tmux

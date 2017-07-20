#!/bin/bash

if [ -e "$HOME/.vimrc" ]; then mv "$HOME/.vimrc" "$HOME/.vimrc.bak"; fi
if [ -e "$HOME/.vim" ]; then mv "$HOME/.vim" "$HOME/.vim.bak"; fi

ln -s $(pwd)/tmux/tmux.conf.symlink ~/.tmux.conf
ln -s $(pwd)/vim/vimrc.symlink ~/.vimrc
ln -s $(pwd)/vim/vimfolder.symlink/ ~/.vim

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install plugins from Vundle
vim +PluginInstall +qall

# Install YouCompleteMe
cd ~/.vim/bundle/YouCompleteMe
if uname -s | grep --quiet Linux; then
    sudo apt-get install build-essential cmake
    sudo apt-get install python-dev python3-dev
else
    brew install cmake
fi
./install.py --clang-completer
cd $OLDPWD

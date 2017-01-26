#!/bin/bash

if [ -e "$HOME/.vimrc" ]; then mv "$HOME/.vimrc" "$HOME/.vimrc.bak"; fi
if [ -e "$HOME/.vim" ]; then mv "$HOME/.vim" "$HOME/.vim.bak"; fi

ln -s $(pwd)/tmux/tmux.conf.symlink ~/.tmux.conf
ln -s $(pwd)/vim/vimrc.symlink ~/.vimrc
ln -s $(pwd)/vim/vimfolder.symlink/ ~/.vim

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install plugins from Vundle
vim +PluginInstall +qall

#!/bin/bash

if [ -e .vimrc ]; then mv .vimrc .vimrc.bak; fi
if [ -e .vim ]; then mv .vim .vim.bak; fi

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

ln -s $(pwd)/tmux/tmux.conf.symlink ~/.tmux.conf
ln -s $(pwd)/vim/vimrc.symlink ~/.vimrc
ln -s $(pwd)/vim/vimfolder.symlink/ ~/.vim

# Install plugins from Vundle
vim +PluginInstall +qall

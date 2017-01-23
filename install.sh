#!/bin/bash

if [ -e .vimrc ]; then mv .vimrc .vimrc.bak; fi
if [ -e .vim ]; then mv .vim .vim.bak; fi

ln -s $(pwd)/tmux/tmux.conf.symlink ~/.tmux.conf
ln -s $(pwd)/vim/vimrc.symlink ~/.vimrc
ln -s $(pwd)/vim/vimfolder.symlink/ ~/.vim

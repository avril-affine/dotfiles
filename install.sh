#!/bin/bash

cp tmux/tmux.conf.symlink ~/.tmux.conf
cp vim/vimrc.symlink ~/.vimrc
mkdir -p ~/.vim
cp -r vim/vimfolder.symlink/* ~/.vim

#!/usr/bin/env bash

mkdir -p "$HOME/.config"
ln -s $HOME/.vimrc $HOME/.vim/init.vim
ln -s $HOME/.vim $HOME/.config/nvim

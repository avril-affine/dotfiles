#!/usr/bin/env bash

sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# remove default oh-my-zsh .zshrc
if [ $? -eq 0 ]; then
    rm $HOME/.zshrc
    touch $HOME/.zshrc
else
    exit 1
fi

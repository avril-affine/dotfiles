#!/usr/bin/env bash

if uname -s | grep --quiet Linux; then
    curl -O http://www.zsh.org/pub/old/zsh-5.6.1.tar.xz
    tar -xJ -f zsh-5.6.1.tar.xz
    pushd zsh-5.6.1
    ./configure
    make
    sudo make install
    popd
    rm -rf zsh-5.6.1 zsh-5.6.1.tar.xz
    sudo sh -c 'echo /usr/local/bin/zsh >> /etc/shells'
else
    brew install zsh
    sudo sh -c 'echo /usr/local/bin/zsh >> /etc/shells'
fi

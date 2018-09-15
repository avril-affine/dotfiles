#!/usr/bin/env bash

git clone https://github.com/tmux/tmux.git $HOME/tmux
pushd $HOME/tmux
git reset --hard 2c6af068d7f024b3c725777f78ee4feb1813bcf9
sh autogen.sh
if uname -s | grep --quiet Linux; then
    ./configure && make
else
    ./configure CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib" && make
fi
sudo cp ./tmux /usr/local/bin/tmux
popd
rm -rf $HOME/tmux

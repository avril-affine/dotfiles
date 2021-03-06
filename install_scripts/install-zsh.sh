#!/usr/bin/env bash

if uname -s | grep --quiet Linux; then
    curl -O https://sourceforge.net/projects/zsh/files/zsh/5.8/zsh-5.8.tar.xz/download
    tar -xJ -f zsh-5.8.tar.xz
    pushd zsh-5.8
    ./configure
    make
    sudo make install
    popd
    rm -rf zsh-5.8 zsh-5.8.tar.xz
    sudo sh -c 'echo /usr/local/bin/zsh >> /etc/shells'
else
    brew install zsh
    sudo sh -c 'echo /usr/local/bin/zsh >> /etc/shells'
fi

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# remove default oh-my-zsh .zshrc
if [ $? -eq 0 ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo "[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh" > $HOME/.zshrc
    echo "[ -f $HOME/.zshrc.global ] && source $HOME/.zshrc.global" >> $HOME/.zshrc
    echo ". $HOME/anaconda3/etc/profile.d/conda.sh" >> $HOME/.zshrc
else
    exit 1
fi


if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script."
  exit
fi

# build
APT_PKGS=" \
    automake \
    build-essential \
    pkg-config \
    libevent-dev \
    libncurses5-dev \
"

# programs
APT_PKGS=" \
    autojump \
    curl \
    git \
    neovim \
    npm \
    ripgrep \
    zsh \
    $APT_PKGS \
"

set -ex

symlinks() {
    for SRC in $(find ~+ -name \*.symlink)
    do 
        local TARGET=$(echo $SRC | sed 's/.*\/\(.*\)\.symlink$/\1/')
        ln -sf $SRC "$HOME/.$TARGET"
    done
}

vim() {
    mkdir -p "$HOME/.config"
    ln -sf $HOME/.vim $HOME/.config/nvim

    # nonicons
    git clone https://github.com/yamatsum/nonicons
    mkdir -p ~/.local/share/fonts
    cp nonicons/dist/*.tff ~/.local/share/fonts
    fc-cache -f -v

    # pyright
    npm install -g pyright

    # lua-language-server
    mkdir /etc/lua-language-server
    curl https://api.github.com/repos/sumneko/lua-language-server/releases | grep linux-x64 | grep browser_download_url | grep -Eo 'https://[^\"]*' | sed -n '1p' | tar -xz -C /etc/lua-language-server
    ln -s /etc/lua-language-server/bin/lua-language-server /usr/local/bin
}

packages() {
    add-apt-repository -y ppa:neovim-ppa/unstable

    apt update
    apt install -y --no-install-recommends $APT_PKGS
}

zsh() {
    chsh -s $(which zsh)

    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # remove default oh-my-zsh .zshrc
    if [ $? -eq 0 ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/wting/autojump ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump
        git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
        echo "[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh" > $HOME/.zshrc
        echo "[ -f $HOME/.zshrc.global ] && source $HOME/.zshrc.global" >> $HOME/.zshrc
        echo ". $HOME/anaconda3/etc/profile.d/conda.sh" >> $HOME/.zshrc

        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    else
        return 1
    fi
}

main() {
    # su $(logname) -c symlinks
    # packages
    su $(logname) -c zsh
    # su $(logname) -c vim
}

export -f symlinks packages zsh vim
main

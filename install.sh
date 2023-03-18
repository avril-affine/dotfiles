#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script."
  exit
fi

HOMEDIR=$( getent passwd "$(logname)" | cut -d: -f6 )

BREW_PKGS=" \
    tmux \
    neovim \
    npm \
    fontconfig \
    ripgrep \
    autojump \
    lazygit \
"

# build
APT_PKGS=" \
    automake \
    build-essential \
    pkg-config \
    libevent-dev \
    libncurses5-dev \
"

APT_PKGS=" \
    autojump \
    curl \
    fontconfig \
    git \
    neovim \
    npm \
    ripgrep \
    zsh \
    $APT_PKGS \
"

set -ex

function install_symlinks() {
    for SRC in $(find ~+ -name \*.symlink); do 
	local TARGET="$HOME/.$(echo $SRC | sed 's/.*\/\(.*\)\.symlink$/\1/')"
	if [[ -L $TARGET && -d $TARGET ]]; then
            rm $TARGET
	fi
        ln -sf "$SRC" "$TARGET"
    done
}

function install_neovim_config() {
    mkdir -p ~/.config
    if [[ -L ~/.config/nvim && -d ~/.config/nvim ]]; then
        rm ~/.config/nvim
    fi
    ln -sf ~/.vim ~/.config/nvim

    # nonicons
    git clone https://github.com/yamatsum/nonicons ~/nonicons
    mkdir -p ~/.local/share/fonts
    cp nonicons/dist/*.ttf ~/.local/share/fonts
    fc-cache -f -v
    rm -rf ~/nonicons

    # TODO: install lua-language-server correctly for arm/x86
    # lua-language-server
    # mkdir /etc/lua-language-server
    # curl https://api.github.com/repos/sumneko/lua-language-server/releases \
    #     | grep linux-x64 \
    #     | grep browser_download_url \
    #     | grep -Eo 'https://[^\"]*' \
    #     | sed -n '1p' \
    #     | xargs -I{} wget {} -O - \
    #     | tar -xz -C /etc/lua-language-server
    # ln -sf /etc/lua-language-server/bin/lua-language-server /usr/local/bin

    git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

    vim +PackerInstall +PackerCompile +qall

    pip install neovim
}

function install_packages() {
    if [[ $OSTYPE == 'darwin'* ]]; then
	if ! command -v brew &> /dev/null; then
	    su $(logname) -c "/bin/bash -c $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	fi
	su $(logname) -c "brew install $BREW_PKGS"
    else
        add-apt-repository -y ppa:neovim-ppa/unstable
        apt update
        apt install -y --no-install-recommends $APT_PKGS

        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' |  sed -E 's/.*"v*([^"]+)".*/\1/')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz -C /usr/local/bin lazygit
    fi

    npm install -g pyright
}

function install_zsh() {
    chsh -s $(which zsh)

    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # zsh plugins
    if [ $? -eq 0 ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/wting/autojump ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump
        git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    else
        return 1
    fi
}

function install_miniconda() {
    mkdir -p ~/miniconda3
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm -rf ~/miniconda3/miniconda.sh
    ~/miniconda3/bin/conda init zsh
}

# install
su $(logname) -c "$(declare -f install_symlinks); install_symlinks"

install_packages

if ! [ -d "$HOMEDIR/.oh-my-zsh" ]; then
    su $(logname) -c "$(declare -f install_zsh); install_zsh"
else
    echo "oh-my-zsh is installed. skipping..."
fi

if ! command -v conda; then
    su $(logname) -c "$(declare -f install_miniconda); install_miniconda"
else
    echo "miniconda is installed. skipping..."
fi

if ! [ -d "$HOMEDIR/.config/nvim" ]; then
    su $(logname) -c "$(declare -f install_neovim_config); install_neovim_config"
else
    echo "neovim config is installed. skipping..."
fi

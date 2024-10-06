#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script."
  exit
fi

HOMEDIR=$( getent passwd "$(logname)" | cut -d: -f6 )

BREW_PKGS=" \
    stow \
    tmux \
    neovim \
    npm \
    fontconfig \
    ripgrep \
    autojump \
    lazygit \
    ccls \
    wget \
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
    stow \
    autojump \
    curl \
    fontconfig \
    git \
    neovim \
    npm \
    ripgrep \
    zsh \
    ccls \
    $APT_PKGS \
"

set -ex

function install_symlinks() {
    stow -D .
    stow .
}

function install_neovim_config() {
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

    pip install neovim
    nvim +UpdateRemotePlugins +TSInstall all +qall
}

function install_packages() {
    if [[ $OSTYPE == 'darwin'* ]]; then
        if ! command -v brew &> /dev/null; then
            # FIXME: doesn't install brew correctly. fix quotes.
            # su $(logname) -c "/bin/bash -c $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            echo "install homebrew"
            exit 1
        fi
        su $(logname) -c "brew install $BREW_PKGS"
    else
        add-apt-repository -y ppa:neovim-ppa/unstable
        apt update
        apt install -y --no-install-recommends $APT_PKGS
        update-alternatives --install $(which vim) vim $(which nvim) 1

        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' |  sed -E 's/.*"v*([^"]+)".*/\1/')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz -C /usr/local/bin lazygit
        rm lazygit.tar.gz
    fi

    npm install -g pure-prompt
}

function install_zsh() {
    # chsh -s $(which zsh)

    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    echo "[ -f ~/.zshrc.global ] && source ~/.zshrc.global" >> ~/.zshrc

    # zsh. plugins
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
    if [[ $OSTYPE = 'darwin'* ]]; then
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda3/miniconda.sh
    else
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
    fi
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm -rf ~/miniconda3/miniconda.sh
    ~/miniconda3/bin/conda init zsh
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
}

function install_fonts() {
    if [ ! -d "$HOMEDIR/monaco-nerd-fonts" ]; then
        su $(logname) -c "git clone https://github.com/Karmenzind/monaco-nerd-fonts ~/monaco-nerd-fonts"
    fi

    if [[ $OSTYPE = 'darwin'* ]]; then
        su $(logname) -c ' \
            mkdir -p ~/Library/Fonts; \
            cp ~/monaco-nerd-fonts/fonts/* ~/Library/Fonts/;
        '
    else
        fc-cache -fv ~/monaco-nerd-fonts/fonts
    fi
}

install_packages
install_fonts

# install
su $(logname) -c "$(declare -f install_symlinks); install_symlinks"


if ! [ -d "$HOMEDIR/.oh-my-zsh" ]; then
    su $(logname) -c "$(declare -f install_zsh); install_zsh"
else
    echo "oh-my-zsh is installed. skipping..."
fi

if ! command -v conda; then
    su $(logname) -c "set -ex; $(declare -f install_miniconda); install_miniconda"
else
    echo "miniconda is installed. skipping..."
fi

if ! [ -d "$HOMEDIR/.config/nvim" ]; then
    su $(logname) -c "$(declare -f install_neovim_config); install_neovim_config"
else
    echo "neovim config is installed. skipping..."
fi

if [[ $OSTYPE = 'darwin'* ]]; then
    echo "Finish installing nerd fonts: Preferences -> Profiles -> Text -> Monaco Nerd Font Mono"
    echo "Finish installing iterm colors: Preferences -> Profiles -> Colors -> Color Presets... -> Import"
fi

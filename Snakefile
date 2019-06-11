import os
import platform

import util
from snakemake.utils import makedirs

configfile: "config.yml"

# ----------
# FUNCTIONS
# ----------
def is_mac():
    return platform.system() == "Darwin"

def is_ubuntu():
    return platform.linux_distribution()[0] in ["Ubuntu", "debian"]

# ------------
# BUILD PATHS
# ------------
BUILD_DIR = "build"
SYMLINK_DIR = os.path.join(BUILD_DIR, "symlinks")
BREW_DIR = os.path.join(BUILD_DIR, "brew")
APT_DIR = os.path.join(BUILD_DIR, "apt")
SCRIPT_DIR = os.path.join(BUILD_DIR, "install_scripts")
NPM_DIR = os.path.join(BUILD_DIR, "npm")

# ----------
# INIT DIRS
# ----------
makedirs(SYMLINK_DIR)
makedirs(BREW_DIR)
makedirs(SCRIPT_DIR)
makedirs(NPM_DIR)

symlink_targets = [os.path.join(SYMLINK_DIR, target) for target in config["symlinks"]]
brew_targets = [os.path.join(BREW_DIR, target) for target in config["brew"]]
apt_targets = [os.path.join(APT_DIR, target) for target in config["apt"]]
script_targets = [os.path.join(SCRIPT_DIR, target) for target in config["install_scripts"]]
if is_mac():
    script_targets += [os.path.join(SCRIPT_DIR, target) for target in config["mac_install_scripts"]]
if is_ubuntu():
    script_targets += [os.path.join(SCRIPT_DIR, target) for target in config["ubuntu_install_scripts"]]
npm_targets = [os.path.join(NPM_DIR, target) for target in config["npm"]]

# ------
# RULES
# ------
rule all:
    input:
        symlink_targets,
        brew_targets if is_mac() else [],
        apt_targets if is_ubuntu() else [],
        script_targets,
        npm_targets

rule symlinks:
    input:
        symlink_targets

rule _symlinks:
    input:
        lambda wildcards: config["symlinks"][wildcards.symlink_target]
    output:
        os.path.join(SYMLINK_DIR, "{symlink_target}")
    run:
        _input = input[0]
        _output = output[0]
        assert _input.endswith(".symlink")
        input_path = os.path.abspath(_input)
        base = os.path.basename(input_path).replace(".symlink", "")
        output_path = os.path.expanduser("~/.{}".format(base))

        # backup
        if os.path.exists(output_path) and not os.path.islink(output_path):
            shell("mv {path} {path}.bak".format(path=output_path))
        # remove symlink directories
        # TODO: handle directories better
        if os.path.islink(output_path):
            shell("rm {}".format(output_path))
        shell("ln -sf {} {}".format(input_path, output_path))
        shell("touch {output}")

rule install_scripts:
    input:
        "install_scripts/{script_target}"
    output:
        os.path.join(SCRIPT_DIR, "{script_target}")
    shell:
        "bash {input} && touch {output}"

rule brew_packages:
    input:
        target=brew_targets,
        brew=os.path.join(SCRIPT_DIR, "install-brew.sh")

rule _brew_packages:
    params:
        target="{brew_target}"
    output:
        os.path.join(BREW_DIR, "{brew_target}")
    run:
        assert is_mac()
        name = config["brew"][params.target]["name"]
        cask = config["brew"][params.target]["cask"]

        # check if installed
        cmd = "brew cask info {}".format(cask) if cask else "brew list {}".format(name)
        if not util.shell_command(cmd):
            # TODO: check version upgrade
            shell("brew install {}".format(name))
            if cask:
                shell("brew cask install {}".format(name))
        shell("touch {output}")

rule npm:
    params:
        target="{npm_target}"
    output:
        os.path.join(NPM_DIR, "{npm_target}")
    shell:
        "npm list -g {params.target} || "
        "sudo npm install -g {params.target}; "
        "touch {output}"

rule pip:
    params:
        target=config["pip"]
    shell:
        "for target in {params.target}; do pip install target; done"

def zsh_dependencies(wildcards):
    if is_mac():
        return [os.path.join(SCRIPT_DIR, "install-brew.sh")]
    else:
        return []

rule install_zsh:
    input:
        "install_scripts/install-zsh.sh"
    output:
        os.path.join(SCRIPT_DIR, "install-zsh.sh")
    shell:
        "bash {input[0]} && touch {output}"

rule _install_zsh:
    input:
        os.path.join(SCRIPT_DIR, "install-zsh.sh")
    output:
        directory(os.path.expanduser("~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"))
    shell:
        "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "
        "~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

rule apt_packages:
    input:
        target=apt_targets

rule _apt_packages:
    params:
        target="{apt_target}"
    output:
        os.path.join(APT_DIR, "{apt_target}")
    run:
        assert is_ubuntu()
        name = config["apt"][params.target]["name"]
        ppa = config["apt"][params.target]["ppa"]
        alternatives = config["apt"][params.target]["alternatives"]

        # check if installed
        cmd = "dpkg-query -W {}".format(name)
        if not util.shell_command(cmd):
            if ppa:
                shell("sudo add-apt-repository {}".format(ppa))
                shell("sudo apt-get update")
            shell("sudo apt-get install -y {}".format(name))
            for alt in alternatives:
                shell("sudo update-alternatives --install {} {} {} {}".format(
                    alt["link"], alt["name"], alt["path"], alt["priority"]
                ))
                shell("sudo update-alternatives --config {}".format(alt["name"]))
        shell("touch {output}")

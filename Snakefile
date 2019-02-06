import os
import platform
from snakemake.utils import makedirs

configfile: "config.yml"

# ------------
# BUILD PATHS
# ------------
BUILD_DIR = "build"
SYMLINK_DIR = os.path.join(BUILD_DIR, "symlinks")

# ----------
# INIT DIRS
# ----------
makedirs(SYMLINK_DIR)

symlink_targets = [os.path.join(SYMLINK_DIR, path) for path in config["symlinks"]]

# ----------
# FUNCTIONS
# ----------
def is_mac():
    return platform.system() == "Darwin"

def is_ubuntu():
    return platform.linux_distribution()[0] == "Ubuntu"

# ------
# RULES
# ------
rule all:
    input:
        symlink_targets

rule symlinks:
    input: lambda wildcards: config["symlinks"][wildcards.symlink_target]
    output: os.path.join(SYMLINK_DIR, "{symlink_target}")
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
        shell("ln -sf {} {}".format(input_path, output_path))
        shell("touch {output}")

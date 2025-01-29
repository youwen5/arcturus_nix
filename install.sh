# $ nix develop
# <devshell> $ ./install.sh

# Run this script initially (in this directory) from inside a Nix development shell.
# It will create a workspace `dev_ws` in the current directory.
# Only run this script once and use `. ./run.sh` after.
# Dependencies will intentionally not be updated to ensure reproducibility.

chmod +x *.sh
./pull.sh
./build.sh

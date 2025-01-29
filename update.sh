# $ nix develop
# <devshell> $ ./update.sh <all_seaing_vehicle git ref>

# Run this script initially (in this directory) from inside a Nix development shell.
# It will update to the specified git reference or the latest revision of `all_seaing_vehicle` by default.
# Only run this script after `dev_ws` has been appropriately set up.
# Dependencies will intentionally not be updated to ensure reproducibility.

ref=${1:-"main"}

# navigate to revision
echo -e "\e[1mPulling changes for all_seaing_vehicle\e[0m"
echo "====="
cd dev_ws/src/all_seaing_vehicle
git pull
git checkout $ref
cd ..
echo -e "\e[1mDone applying changes.\e[0m"

# trigger rebuild
cd ../..
./build.sh

echo -e "\e[1mDone updating.\e[0m"
echo -e "\e[1mSee above output for further instructions.\e[0m"

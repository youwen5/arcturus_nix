# $ nix develop
# <devshell> $ ./build.sh

# Run this script after `pull.sh` (in this directory) from inside a Nix development shell.
# It will build the relevant Nix package manifests.
# You can run this again to rebuild Nix packages if dependencies change, e.g.

# generate package manifests
echo -e "\e[1mGenerating Nix packages for all_seaing_vehicle and dependencies with ros2nix\e[0m"
echo "====="
cd dev_ws
ros2nix -- $(find -name package.xml)
echo -e "Done generating Nix packages."

# create build artifacts
echo -e "\e[1mGenerating build artifacts and symlinks for ROS.\e[0m"
echo "====="
colcon build --symlink-install
cd ..
chmod +x ./run.sh
echo -e "Done generating build artifacts and symlinks for ROS."

echo -e "\e[1mDone installing.\e[0m"
echo -e "\e[1mUse \`. run.sh module_name node.py\` to build your first node.\e[0m"

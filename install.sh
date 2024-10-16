# $ nix develop
# <devshell> $ ./install.sh

# Run this script initially (in this directory) from inside a Nix development shell.
# It will create a workspace `dev_ws` in the current directory.
# Only run this script once and use `. ./run.sh` after.
# Dependencies will intentionally not be updated to ensure reproducibility.

# create a workspace
echo -e "\e[1mCreating a workspace for all_seaing_vehicle and dependencies in dev_ws/src\e[0m"
echo "====="
mkdir -p ./dev_ws/src
cd ./dev_ws/src
echo -e "\e[1mCreating a workspace for simulator and dependencies in vrx_ws/src\e[0m"
echo "====="
mkdir -p ./vrx_ws/src
cd ./vrx_ws/src
echo -e "\e[1mDone creating workspaces.\e[0m"

# clone all_seaing_vehicle
echo -e "\e[1mCloning all_seaing_vehicle\e[0m"
echo "====="
git clone https://github.com/ArcturusNavigation/all_seaing_vehicle
echo -e "Done cloning all_seaing_vehicle."

# clone vrx
echo -e "\e[1mCloning vrx\e[0m"
echo "====="
git clone https://github.com/ArcturusNavigation/vrx
echo -e "Done cloning vrx."

# clone local dependencies

# echo -e "\e[1mCloning local dependencies alongside all_seaing_vehicle\e[0m"
# use v3.9.1 (latest stable version) of robot_localization
# echo -e "\e[1mCloning robot_localization (v3.9.1)\e[0m"
# echo "====="
# git clone --depth 1 https://github.com/cra-ros-pkg/robot_localization
# cd robot_localization
# git fetch --depth 1 origin 7b911bb19ca1fbbbdf0532260b4ca1359fbfcfac > /dev/null 2>&1
# git checkout 7b911bb19ca1fbbbdf0532260b4ca1359fbfcfac > /dev/null 2>&1
# cd ..
# echo -e "Done cloning robot_localization."

# use latest commit (no version tag) of ros2-keyboard
echo -e "\e[1mCloning ros2-keyboard (f1d8412)\e[0m"
echo "====="
git clone --depth 1 https://github.com/cmower/ros2-keyboard
cd ros2-keyboard
git fetch --depth 1 origin f1d84122b40cbeec05d54ce90d35c8d16b47bbad > /dev/null 2>&1
git checkout f1d84122b40cbeec05d54ce90d35c8d16b47bbad > /dev/null 2>&1
cd ..
echo -e "Done cloning ros2-keyboard."

# build all_seaing_vehicle and all dependencies
echo -e "\e[1mGenerating Nix packages for all_seaing_vehicle and dependencies with ros2nix\e[0m"
echo "====="
cd ..
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

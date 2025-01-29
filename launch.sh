# ./launch.sh <launch file>

# This script does not need to be run from a devshell since it will spawn its own fully reproducible devshell.
# Specify a launch file in `all_seaing_bringup` to start.
# If no launch file is specified, it runs the default Nix launch files marked for testing, which must be present on the current revision of `all_seaing_vehicle`.
# This can only be run after `./install.sh`, though you may also want to update (`./update.sh`) your revision
# before running the launch files.

# For running other launch configurations in a similarly reproducible environment, use `nix develop -i`
# and then run `. ./source.sh` followed by the ROS launch commands.

file=${1:-"vehicle-nix-test.py"}
nix develop -i --command bash -c ". ./source.sh; ros2 launch all_seaing_bringup ${file}"

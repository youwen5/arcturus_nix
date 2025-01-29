# $ nix develop
# <devshell> $ ./hash.sh

# Use this to figure out what versions you are using for reproducibility purposes.

echo -e "\e[1mgithub:ArcturusNavigation/arcturus_nix\e[0m"
git rev-parse HEAD

DIR="dev_ws/src/all_seaing_vehicle"
if [ ! -d "$DIR" ]; then
    echo -e "\e[1m\e[0;31mError: Directory '$DIR' does not exist.\e[0;31m\e[0m" >&2
    exit 1
fi

cd dev_ws/src/all_seaing_vehicle
echo -e "\n\e[1mgithub:ArcturusNavigation/all_seaing_vehicle\e[0m"
git rev-parse HEAD

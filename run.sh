# main routine
main() {
  # build with nix
  cd dev_ws
  echo -e "\e[1mBuilding module with Nix (see result/ for artifacts).\e[0m"
  nixName=$(echo "$1" | tr '_' '-')
  echo "$nixName"
  nix-build -A rosPackages.humble.$nixName
  echo "Done building module with Nix."

  # source manifests
  echo -e "\e[1mAdding all modules to ROS environment.\e[0m"
  dirs=(`cd install; ls -d */ | sed 's:/$::'`)
  for dir in "${dirs[@]}"; do
    path="install/${dir}/share/${dir}/local_setup.bash"
      if [[ -f "$path" ]]; then
        source $path
      fi
  done
  echo "Done adding all modules to ROS environment."

  # run module
  echo -e "\e[1mRunning node.\e[0m"
  ros2 run $1 $2
  echo -e "\e[1mDone.\e[0m"
  echo -e "\e[1mTo run nodes in this module from now on, even after updates, you can use \`ros2 run ${1} node.py\`.\e[0m"
  cd ..
}

# show help and exit
if [[ "$1" == "-h" || "$1" == "--help" ]] ; then
  echo -e "\e[1mUsage\e[0m: . ./run.sh module_name node.py [-h]"
  echo -e "\e[1mNote\e[0m: Once you've built a module, you can run nodes within it with \`ros2 run module_name node.py\` instead of using this script."
  echo -e "\e[1mImportant\e[0m: Use a period (.) before the script name so that environment changes occur in your current shell session."
  echo -e "Wrapper around ros2 run that also sources necessary build files and regenerates Nix artifacts (see result/)."
  echo -e "Run from root directory (dev_ws/install/ should be a subdirectory)."
else
  main "$1" "$2"
fi

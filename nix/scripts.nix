{
  install.exec = ''
    # Run this script initially (in this directory) from inside a Nix development shell.
    # It will create a workspace `dev_ws` in the current directory.
    # Only run this script once and use `. ./run.sh` after.
    # Dependencies will intentionally not be updated to ensure reproducibility.

    # create a workspace
    echo -e "\e[1mCreating a workspace for all_seaing_vehicle and dependencies in dev_ws/src\e[0m"
    echo "====="
    mkdir -p ./dev_ws/src
    echo -e "\e[1mDone creating workspaces.\e[0m"

    # clone all_seaing_vehicle
    echo -e "\e[1mCloning all_seaing_vehicle\e[0m"
    echo "====="
    cd ./dev_ws/src
    git clone https://github.com/ArcturusNavigation/all_seaing_vehicle
    cd all_seaing_vehicle
    git checkout q9i/nix-launch
    cd ..
    echo -e "Done cloning all_seaing_vehicle."

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
  '';

  run.exec = ''
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
      for dir in "''${dirs[@]}"; do
        path="install/''${dir}/share/''${dir}/local_setup.bash"
          if [[ -f "$path" ]]; then
            source $path
          fi
      done
      echo "Done adding all modules to ROS environment."

      # run module
      echo -e "\e[1mRunning node.\e[0m"
      ros2 run $1 $2
      echo -e "\e[1mDone.\e[0m"
      echo -e "\e[1mTo run nodes in this module from now on, even after updates, you can use \`ros2 run ''${1} node.py\`.\e[0m"
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
  '';

  source.exec = ''
    # main routine
    main() {
      # source manifests
      cd dev_ws
      echo -e "\e[1mAdding all modules to ROS environment.\e[0m"
      dirs=(`cd install; ls -d */ | sed 's:/$::'`)
      for dir in "''${dirs[@]}"; do
        path="install/''${dir}/share/''${dir}/local_setup.bash"
          if [[ -f "$path" ]]; then
            source $path
          fi
      done
      echo "Done adding all modules to ROS environment."
      cd ..
    }

    # show help and exit
    if [[ "$1" == "-h" || "$1" == "--help" ]] ; then
      echo -e "\e[1mUsage\e[0m: . ./source.sh [-h]"
      echo -e "\e[1mNote\e[0m: You can run nodes within a module with \`ros2 run module_name node.py\` after using this script."
      echo -e "\e[1mImportant\e[0m: Use a period (.) before the script name so that environment changes occur in your current shell session."
      echo -e "Sources necessary build files from ."
      echo -e "Run from root directory (dev_ws/install/ should be a subdirectory)."
    else
      main
    fi
  '';
}

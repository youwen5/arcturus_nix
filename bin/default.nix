{
  # nix support
  stdenvNoCC,
  writeShellScript,
  lib,

  # git commit of self (will be "unstable" if working tree dirty)
  rev,

  # git repos
  arcturus-tree,
  ros2-keyboard,

  # build tools
  ros2nix,
  colcon,
  git,
}:
let
  # Run this script after `pull.sh` (in this directory) from inside a Nix development shell.
  # It will build the relevant Nix package manifests.
  # You can run this again to rebuild Nix packages if dependencies change, e.g.
  # add other ROS packages here
  scripts = lib.attrsToList rec {
    # Run this script initially (in this directory) from inside a Nix development shell.
    # It will create a workspace `dev_ws` in the current directory.
    # The version of `all_seaing_vehicle` is the one specified or the latest revision by default.
    # Only run this script once and use `./build.sh` after.
    # Dependencies will intentionally not be updated to ensure reproducibility.
    pull = writeShellScript "pull.sh" ''
      # dynamically inject the hash from flake
      ref=''${1:-"${arcturus-tree.rev}"}

      # create a workspace
      echo -e "\e[1mCreating a workspace for all_seaing_vehicle and dependencies in dev_ws/src\e[0m"
      echo "====="
      mkdir -p ./dev_ws/src
      echo -e "\e[1mDone creating workspaces.\e[0m"

      # clone all_seaing_vehicle
      echo -e "\e[1mCloning all_seaing_vehicle\e[0m"
      echo "====="
      cd ./dev_ws/src
      # we could get this from the flake, but we want to be able to hack on
      # code so this is a compromise
      ${git}/bin/git clone https://github.com/ArcturusNavigation/all_seaing_vehicle
      cd all_seaing_vehicle
      ${git}/bin/git checkout $ref
      cd ..
      echo -e "Done cloning all_seaing_vehicle."

      # use latest commit (no version tag) of ros2-keyboard
      echo -e "\e[1mLinking ros2-keyboard (f1d8412)\e[0m"

      # link the ros2-keyboard version pinned in our flake to the directory
      ln -s ${ros2-keyboard} ros2-keyboard

      echo -e "\e[1mDone fetching repositories.\e[0m"
      echo -e "\e[1mUse \`./build.sh\` before running your first node.\e[0m"
    '';

    source = writeShellScript "source.sh" ''
      # main routine
      main() {
      	# source manifests
      	cd dev_ws
      	echo -e "\e[1mAdding all modules to ROS environment.\e[0m"
      	dirs=($(
      		cd install
      		ls -d */ | sed 's:/$::'
      	))
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
      if [[ "$1" == "-h" || "$1" == "--help" ]]; then
      	echo -e "\e[1mUsage\e[0m: . ./source.sh [-h]"
      	echo -e "\e[1mNote\e[0m: You can run nodes within a module with \`ros2 run module_name node.py\` after using this script."
      	echo -e "\e[1mImportant\e[0m: Use a period (.) before the script name so that environment changes occur in your current shell session."
      	echo -e "Sources necessary build files from ."
      	echo -e "Run from root directory (dev_ws/install/ should be a subdirectory)."
      else
      	main
      fi

    '';

    get-versions = writeShellScript "get-versions.sh" ''
      echo -e "\e[1mgithub:ArcturusNavigation/arcturus_nix\e[0m"
      if [ "${rev}" == 'unstable' ]; then
        echo 'your working tree is dirty, you have uncommitted changes.'
      else
        echo 'commit: ${rev}'
      fi

      echo -e "\n\e[1mgithub:ArcturusNavigation/all_seaing_vehicle\e[0m"
      echo 'commit: ${arcturus-tree.rev}'
    '';

    # Run this script initially (in this directory) from inside a Nix development shell.
    # It will create a workspace `dev_ws` in the current directory.
    # Only run this script once and use `. ./run.sh` after.
    # Dependencies will intentionally not be updated to ensure reproducibility.
    # install = writeShellScript "install.sh" ''
    #   ${pull}
    #   ${build}
    # '';
  };
in
stdenvNoCC.mkDerivation {
  pname = "arcturus-scripts";
  version = rev;

  phases = [
    "installPhase"
    "fixupPhase"
  ];

  buildInputs = [
    git
    ros2nix
    colcon
  ];

  installPhase =
    ''
      mkdir -p $out/bin
    ''
    + builtins.concatStringsSep "\n" (
      builtins.map (x: "ln -s ${x.value} $out/bin/arcturus-${x.name}") scripts
    );

  meta = {
    maintainers = [ lib.maintainers.youwen5 ];
    platforms = lib.platforms.linux;
  };
}

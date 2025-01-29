{
  inputs = {
    ros2nix.url = "github:wentasah/ros2nix";

    # important for ros overlay to work
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    nix-ros-overlay.url = "github:arcturusnavigation/nix-ros-overlay/develop";

    # for development
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    arcturus-tree = {
      url = "github:ArcturusNavigation/all_seaing_vehicle/q9i/nix-launch";
      flake = false;
    };

    ros2-keyboard = {
      url = "github:cmower/ros2-keyboard";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nix-ros-overlay,
      ros2nix,
      nixpkgs,
      pre-commit-hooks,
      arcturus-tree,
      ros2-keyboard,
    }:
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "arcturus";
          LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
          packages = [
            # basic development tasks
            pkgs.git
            pkgs.bash

            # ros build tools
            pkgs.colcon
            ros2nix.packages.${pkgs.system}.ros2nix

            # project system dependencies
            pkgs.geographiclib
            pkgs.python3Packages.rosdep
            pkgs.python3Packages.scipy
            pkgs.python3Packages.transforms3d
            pkgs.python3Packages.torch
            pkgs.python3Packages.pyserial
            pkgs.SDL
            pkgs.yaml-cpp

            # add other system packages here
            (
              with pkgs.rosPackages.humble;
              buildEnv {
                paths = [
                  # empirically determined list of project ROS dependencies
                  ros-core
                  boost
                  ament-cmake-core
                  angles
                  diagnostic-updater
                  geographic-msgs
                  message-filters
                  tf-transformations
                  tf2-ros-py
                  tf2-eigen
                  tf2-geometry-msgs
                  yaml-cpp-vendor
                  python-cmake-module
                  rviz-common
                  tf2-sensor-msgs
                  mavros-msgs
                  pcl-ros
                  cv-bridge
                  image-geometry
                  rviz-satellite
                  rviz-default-plugins
                  rosbag2-py

                  # for simulation (requires insecure packages)
                  # gazebo-ros

                  # for launch
                  mavros
                  robot-localization
                  velodyne-pointcloud

                  # add other ROS packages here
                ];
              }
            )
          ];

          shellHook = ''
            alias install="./install.sh"
            alias pull="./pull.sh"
            alias build="./build.sh"
            alias update="./update.sh"
            alias run=". ./run.sh"
            alias launch="./launch.sh"
            alias hash="./hash.sh"
          '';
        };

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
              shfmt.enable = true;
              markdownlint.enable = true;
            };
          };
        };

        devShells.dev = pkgs.mkShell {
          name = "development";

          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;

          packages = [
            # basic development tasks
            pkgs.git
            pkgs.bash
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;

        packages = rec {
          default = pkgs.callPackage ./bin {
            inherit arcturus-tree ros2-keyboard env;
            inherit (ros2nix.packages.${pkgs.stdenv.targetPlatform.system}) ros2nix;
            rev = if (self ? rev) then self.rev else "unstable";

          };
          env = (
            with pkgs.rosPackages.humble;
            (buildEnv {
              paths = [
                # empirically determined list of project ROS dependencies
                ros-core
                boost
                ament-cmake-core
                angles
                diagnostic-updater
                geographic-msgs
                message-filters
                tf-transformations
                tf2-ros-py
                tf2-eigen
                tf2-geometry-msgs
                yaml-cpp-vendor
                python-cmake-module
                rviz-common
                tf2-sensor-msgs
                mavros-msgs
                pcl-ros
                cv-bridge
                image-geometry
                rviz-satellite
                rviz-default-plugins
                rosbag2-py

                # for simulation (requires insecure packages)
                # gazebo-ros

                # for launch
                mavros
                robot-localization
                velodyne-pointcloud

                # add other ROS packages here
              ];
            }).overrideAttrs
              (prev: {
                buildPhase =
                  prev.buildPhase
                  + ''
                    cat << EOF > build.sh

                    # generate package manifests
                    echo -e "\e[1mGenerating Nix packages for all_seaing_vehicle and dependencies with ros2nix\e[0m"
                    echo "====="
                    cd dev_ws
                    ${ros2nix}/bin/ros2nix -- \$(find -name package.xml)
                    echo -e "Done generating Nix packages."

                    # create build artifacts
                    echo -e "\e[1mGenerating build artifacts and symlinks for ROS.\e[0m"
                    echo "====="
                    ${pkgs.colcon}/bin/colcon build --symlink-install
                    cd ..
                    echo -e "Done generating build artifacts and symlinks for ROS."

                    echo -e "\e[1mDone installing.\e[0m"
                    echo -e "\e[1mUse \`. run.sh module_name node.py\` to build your first node.\e[0m"
                    EOF

                    install -Dm755 build.sh $out/bin/arcturus-builder

                    makeWrapper "$out/bin/arcturus-builder" "$out/bin/arcturus-builder-wrapped" \
                      --prefix PATH : "$out/bin" \
                      --prefix LD_LIBRARY_PATH : "$out/lib:${pkgs.lib.makeLibraryPath [ pkgs.openssl.out ]}" \
                      --prefix PYTHONPATH : "$out/${pkgs.python.sitePackages}" \
                      --prefix CMAKE_PREFIX_PATH : "$out" \
                      --prefix AMENT_PREFIX_PATH : "$out" \
                      --prefix ROS_PACKAGE_PATH : "$out/share" \
                      --prefix GZ_CONFIG_PATH : "$out/share/gz" \
                      --set ROS_DISTRO '${ros-environment.rosDistro}' \
                      --set ROS_VERSION '${toString ros-environment.rosVersion}' \
                      --set ROS_PYTHON_VERSION '${lib.versions.major python.version}' \
                      ''${rosWrapperArgs[@]}
                  '';
              })
          );
        };
      }
    );
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}

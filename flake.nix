{
  inputs = {
    ros2nix.url = "github:wentasah/ros2nix";

    # important for ros overlay to work
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    nix-ros-overlay.url = "github:arcturusnavigation/nix-ros-overlay/develop";

    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
  };
  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        { pkgs, system, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.nix-ros-overlay.overlays.default
            ];
          };

          devenv.shells.default = {
            name = "arcturus";
            # LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
            packages =
              with pkgs;
              [
                # add other non-ROS packages here
                git
                bash
                colcon
                geographiclib
                python3Packages.rosdep
                python3Packages.scipy
                python3Packages.transforms3d
                python3Packages.torch
                python3Packages.pyserial
                SDL
                yaml-cpp
              ]
              ++ [
                inputs.ros2nix.packages.${pkgs.system}.ros2nix
                (
                  with pkgs.rosPackages.humble;
                  buildEnv {
                    paths = [
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

            scripts = import ./nix/scripts.nix;
          };
          formatter = pkgs.nixfmt-rfc-style;
        };
    };
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}

{
  inputs = {
    ros2nix.url = "github:wentasah/ros2nix";

    # important for ros overlay to work
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    nix-ros-overlay.url = "github:arcturusnavigation/nix-ros-overlay/develop";
  };
  outputs =
    {
      self,
      nix-ros-overlay,
      ros2nix,
      nixpkgs,
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
          name = "Arcturus (tiny)";
          LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
          packages = [
            pkgs.git
            pkgs.bash
            pkgs.colcon
            pkgs.geographiclib
            pkgs.python3Packages.rosdep
            pkgs.python3Packages.scipy
            pkgs.python3Packages.transforms3d
            pkgs.python3Packages.torch
            pkgs.SDL
            pkgs.yaml-cpp
            ros2nix.packages.${pkgs.system}.ros2nix
            # add other non-ROS packages here
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
        };
        formatter = pkgs.nixfmt-rfc-style;
      }
    );
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}

# main routine
main() {
	# source manifests
	cd dev_ws
	echo -e "\e[1mAdding all modules to ROS environment.\e[0m"
	dirs=($(
		cd install
		ls -d */ | sed 's:/$::'
	))
	for dir in "${dirs[@]}"; do
		path="install/${dir}/share/${dir}/local_setup.bash"
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

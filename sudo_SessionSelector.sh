#!/bin/bash
# Session Decider - Main Handler(2)

# Note : When I have the required priviliges (root) account

commands=()

createSessionHandler() {
	IFS=$1
	path_to_mainSessionHandler="sessionHandler.sh"
	echo -e " #!/bin/bash\n" > $path_to_mainSessionHandler
	echo "commands=(" >> $path_to_mainSessionHandler
	for command in ${commands[@]}; do
		command=" \"$command\" "
		echo $command >> $path_to_mainSessionHandler
	done
	echo -e ") \n" >> $path_to_mainSessionHandler
	IFS=$'; \t\n'
	path_to_baseSessionHandler="base_SessionHandler"
	while IFS= read -r line; do
		echo "$line" >> $path_to_mainSessionHandler
	done < $path_to_baseSessionHandler
	chmod +x $path_to_mainSessionHandler
	
	echo "[+] Session Handler is Ready"
}

selectSession() {
	stop=0
	
	while [[ $stop -eq 0 ]]; do
		echo -e "\n 1. Installation(i)\n 2. Deletion(d)\n 3. Remove Files (r)\n 4. Other(o)\n 5. Continue(y)\n Exit(Any Other)\n "
		read -p " Choice : " choice
		printf "\n\n"
		case $choice in
			'i' | 'I'|'1')
				installation
				;;
			'd' | 'D'|'2')
				deletion
				;;
			'r'|'R'|'3')
				removeFiles
				;;
			'o'|'O'|'4')
				miscelleanous
				;;
			'y'|'Y'|'c'|'C'|'5')
				stop=1
				;;
			*)
				if [ ! -z "$commands" ]; then
					printf "You have saved Data ?\n"
					read -p "Do you want to Exit (y/n) " choice
					case $choice in
						'y'|'Y')
							stop=2
							;;
						*)
							stop=0
							;;
					esac
				else
					stop=2
				fi
		esac
	done
		
	if [[ $stop -eq 1 ]]; then
		
		if [ ! -z "$commands" ]; then
			exitSession
			createSessionHandler
			exit 0
		else
			printf "[-] Empty Session\n"
			exit 2551
		fi
	else
		printf "[-] Empty Session\n"
		exit -1
	fi
}

exitSession() {
	echo " Perform Actions on Exit \n 1. Shutdown 2. Restart"
	read -p " Choice : " choice
	case $choice in
		's'|'S'|'1')
			printf ""
			commands+=("sudo shutdown now")
			;;
		'n'|'N'|'2')
			commands+=("sudo reboot")
			;;
		*)
			:
			;;
	esac
	
}

pipInstallation() {
	read -p "Enter package name : " packages
	IFS=' ,'
	for package in ${packages[@]}; do
		command=" sudo pip install $package"
		commands+=("$command")
	done	
}

aptInstallation() {
	read -p "Enter Package Name(s) with ',' in between : " packages
	IFS=' ,'
	for package in ${packages[@]}; do
		echo "$package"
		command="sudo apt -y install $package"
		commands+=("$command")
	done
}

aptGetInstallation() {
	read -p "Enter Package Name(s) with ',' in between : " packages
	IFS=' ,'
	for package in ${packages[@]}; do
		echo "$package"
		command="sudo apt-get -y install $package"
		commands+=("$command")
	done
}

dpkgInstallation() {
	read -p "Enter Paths to .deb packages : " paths
	IFS=' ,'
	for path in ${paths[@]}; do
		command="sudo dpkg -i $path"
		commands+=("$commands")
	done
}

installation() {
	flag=0
	echo -e "Listing Available Installation Methods\n 1.Pip (p)\n 2.Apt(a)\n 3.Apt-Get(g)\n 4.Wget(w)\n"
	read -p " Choice : " choice
	case $choice in
		'p'|'P'|'1')
			pipInstallation
			;;
		'a'|'A'|'2')
			aptInstallation
			;;
		'g'|'G'|'3')
			aptGetInstallation
			;;
		'w'|'W'|'4')
			wgetInstallation
			;;
		*)
			printf "Unable to recognize I/P\n"
			flag=1
	esac
	
	if [[ $flag -eq 0 ]]; then
		commands+=(" sudo apt autoremove")
		commands+=(" sudo apt autoclean")
	fi
}


deletion() {
	read -p "Enter Package Names (seperated by ,) : " packages
	IFS=' ,'
	for package in ${packages[@]}; do
		command="sudo apt -y purge $package"
		commands+=("$command")
	done
	commands+=(" sudo apt -y autoremove")
	commands+=(" sudo apt -y autoclean")
}

miscelleanous() {
	printf " Please enter commands [ '$)' to exit ] \n Avoid ';' and '\"' in the commands \n"
	stop=0
	while [[ $stop -eq 0 ]]; do
		read -p "#> " command
		if [[ $command == "$)" ]]; then
			break
		elif [[ -z $command ]]; then
			:
		else
			command="$command "
			commands+=("$command")
		fi
	done
}

removeFiles() {
	printf "[--] Note : This Session is to run on User-Priviliges (To prevent damages)"
	printf "Available Options to Perform\n"
	printf " 1. Pattern-Based\n 2. Path-Based\n 3. Miscelleanous\n"
	read -p "Choice : " choice
	printf "[-] Under Development\n"
}

exitSession() {
	echo -e "Action On Exit...\n Shutdown (s) Reboot (r) Any Other To Exit..."
	read -p " Choice : " choice
	case $choice in
		's'|'S'|'1')
			commands+=("sudo shutdown now")
			echo "Shutdown Added..."
			;;
		'r'|'R'|'2')
			commands+=("sudo reboot")
			echo "Shutdown Added..."
			;;
		*)
			;;
	esac	
}

#password=$1
printf "Sudo-Session"
selectSession
return $?

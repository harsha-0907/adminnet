#!/bin/bash
# Session Handler

condition=1
commands=()

portListener() {
	# Traffic Listener on port 23333
	# We are using ncat to actively listen to port traffic
	echo "[+] Port Listener Active..."
	ncat -lp 23333 -k &
	bid=$!
	while [[ $condition -gt 0 ]]; do
		
		printf "$condition\n"
	done
	echo "[-] Port Exit"
}

getCredentials() {
 	path=$1
 	credentials=()
 	while IFS= read -r credential; do
 		credentials+=("$credential")
 	done<$path
 	echo ${credentials[@]}
 }
 
commandCreatorSame() {
 	read -p "Username : " username
 	read -p "Password : " password
 	read -p "Is the user SuperUser(root/admin) ? (y/n) " choice
 	flag=0
 	
 	# Create Commands to create sessions
 	case $choice in
 		'Y'|'y')	# -> Has root priviliges
 			# Use sessionSelector
 			flag=1
 			;;
 		'n'|'N')	# -> Has no root privilige
 			# Use sessionSelector1.sh
 			# Send the password as a parameter
 			flag=2
 			;;
 		*)
 			exit 0
 			;;
 	esac
 	if [[ $flag -eq 1 ]]; then
 		path="sudo_same.txt"
		cat $path
 		ip_addresses=$(getCredentials $path)
		bash sudo_SessionSelector.sh
	elif [[ $flag -eq 2 ]]; then
		path="non_sudo_same.txt"
		echo -e "Selected Targets : \n"
		cat $path
		ip_addresses=$(getCredentials $path)
 		bash non_sudo_SessionSelector.sh $password
 	fi
 	IFS=' '
	number_of_commands=0
	for credential in ${ip_addresses[@]}; do
		while IFS= read -r ip_addr ; do
			command="sshpass -p '$password' ssh -o StrictHostKeyChecking=no $username@$ip_addr 'bash -s' < sessionHandler.sh $ip_addr ;"
			commands+=("$command")
			((number_of_commands++))
		done<<< $credential
	done
	
	# Commands Created
	#IFS='^'
	#for command in ${commands[@]}; do
	#	printf "$command\n"
	#done
	IFS=$' \t\n'
	return $number_of_commands
 }

commandCreatorUnique() {
	credentials=$@
	number_of_commands=0
	read -p "Is the user SuperUser (root/admin) ? (y/n) " choice
	flag=0
	case $choice in
		'y'|'Y')	# -> Has root priviliges
			flag=1
			# Creating Commands
			for credential in ${credentials[@]}; do
				while IFS=', ' read -r val1 val2 val3 ; do
					command="sshpass -p '$val3' ssh $val2@$val1 'bash -s' < sessionHandler.sh $val1;"
					commands+=("$command")
					((number_of_commands++))
				done<<< $credential
			done
			# Only un-comment if '^' present in command
			#IFS='^'
			#for command in ${commands[@]}; do
			#	printf "$command\n"
			#done
			;;
		'n'|'N')
			flag=2
			;;
		*)
			flag=-1
			;;
	esac
	
	# Commands Created	
	if [[ $flag -eq 1 ]]; then
		bash sudo_SessionSelector.sh
	elif [[ $flag -eq 2 ]]; then
		printf " [-] Under Development"
		exit 0
	else
		printf " [-] Un-Recognizable Input"
		exit 0
	fi
	return $number_of_commands
}

printArray() {
	IFS=$1
	array=$@
	#IFS=';'
	for element in ${array[@]}; do
		printf "$element\n"
	done
}

batchExecuter() {
	system_commands=$@
	IFS=';'
	for system_command in ${system_commands[@]}; do
		system_command="$system_command &"		# If you need to perform operations simultaneously in bg
		executeCommand $system_command
	done
}

executeCommand() {
	executable_command=$1
	printf "$executable_command\n"
	bash -c "$executable_command"			# Un-Comment to execute Commands
}

#portListener &

echo "Welcome to LeeController..."
echo "Enter Configurations..."
read -p "Are the Systems Same ? (n/y) " choice
flag=0
case $choice in
	'y'|'Y')
		flag=1
		;;
	'n'|'N')
		flag=2
		;;
	*)
		echo -e "Un-Recognized Option\n"
		flag=-1
		;;
esac

if [[ $flag -eq 1 ]]; then
	#read -p " Enter Path to IP-Addresses : " path	# To take file path
	commandCreatorSame ${res[@]}
	
elif [[ $flag -eq 2 ]]; then
	#read -p " Enter Path to Credentials : " path	# # To take file path
	path="worst_target_list.txt"
	# res=$(getCredentials $path)
	commandCreatorUnique ${res[@]}
else
	exit 0
fi
number_of_commands=$?
printf "Return Value $?\n"
if [[ $? -eq 0 ]]; then
	 #SessionHandler is Ready to execute...
	batchExecuter ${commands[@]}
fi

echo "[-] Exiting Legend... "
exit 0

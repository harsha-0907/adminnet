
verifyShell() {
	device_ip=$1
	res=$(ifconfig)
	if [[ ! $res =~ $device_ip ]]; then
		echo -e "[-] $device_ip Inactive"
		return -1
	fi
	echo -e "[+] $device_ip is Active"
	return 0
}

executeCommand() {
	echo $1
	res=$(bash -c "$1")
	echo "$res"
}

reportSession() {
	ip=$1
	message=$@
	echo "$message" | nc $ip 23333 -q 1
}

ip=$1

verifyShell $ip

if [ $? -eq 0 ]; then
	echo "[+] Session Created"
	for command in "${commands[@]}"; do
		executeCommand "$command"
	done
	#reportSession $ip Complete
else
	echo "Exit"
	exit
fi

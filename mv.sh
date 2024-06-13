#!/bin/bash

base_img=""
new_mac=""
new_uuid=""
new_name=""


# $1 com, $2 user, $3 ip, $4 vm|new_vm, $5 path
execute(){
	case $1 in
		define)
			ssh -n $2@$3 "cd /misc/alumnos/as2/as22023/$2; virsh -c qemu:///system define $4.xml"	
			;;
		backup)
			scp "$2"@central.cps.unizar.es:/misc/alumnos/as2/as22023/"$2"/"$4".qcow2 "/home/benedi/as2/$5/."
			scp "$2"@central.cps.unizar.es:/misc/alumnos/as2/as22023/"$2"/"$4".xml "/home/benedi/as2/$5/."
			;;
		run)
			execute "define" "$2" "$3" "$4" "$5"
			execute "start" "$2" "$3" "$4" "$5"
			;;
		
		create)
			remote_folder="/misc/alumnos/as2/as22023/$2"
			ssh "$2"@"$3" "
				cd $remote_folder ;
				qemu-img create -f qcow2 -o backing_file=$base_img.qcow2 -F qcow2 $4.qcow2 ;
				cp $base_img.xml $4.xml ;
				chmod 660 $4*
				sed -i \"s|<mac address='[^']*'/>|<mac address='$new_mac'/>|\" \"$4\".xml;
				sed -i \"s|<uuid>[^<]*</uuid>|<uuid>$new_uuid</uuid>|\" \"$4\".xml;
				sed -i \"s|<name>[^<]*</name>|<name>$4</name>|\" \"$4\".xml;
				sed -i \"s|<source file='[^']*'/>|<source file='$remote_folder/$4.qcow2'/>|\" \"$4\".xml;
			"					
			;;
		*)
			virsh -c qemu+ssh://"$2"@"$3"/system "$1" "$4"
			;;
	esac	
}

# $1 name_file, $2 user, $3 ip, $4 com, $5 path
read_conf_file(){
	while read -r vm; do
		#echo "$vm"
		execute $4 $2 $3 $vm $path
	done < $1
}

#$1 name, $2 com
check(){
	# Si no se define el nombre 
	if [ "$1" == "" ]
	then
		echo "Introduzca el nombre del fichero o de la maquina"
		exit 1
	fi

	# Si no se define el comando
	if [ "$2" == "" ]
	then
		echo "Introduzca el comando a ejecutar"
		exit 1
	fi
}

ip=155.210.154.204
user=a843826
name=""
com=""
way="individual"
path="."

while [[ $# -gt 0 ]]
do
	case $1 in
		-de)
			com="define"
			shift 1
			;;
		-un)
			com="undefine"
			shift 1
			;;
		-st)
			com="start"
			shift 1
			;;	
		-sh)
			com="shutdown"
			shift 1
			;;
		-ip)
			ip="$2"
			shift 2
			;;
		-n)
			name="$2"
			shift 2
			;;
		-g)
			way="group"
			name="$2"
			shift 2
			;;
		-i)
			way="individual"
			name="$2"
			shift 2
			;;
		-b)
			com="backup"
			path="$2"
			shift 2
			;;
		-r)
			com="run"
			shift 1
			;;
		-c)
			com="create"
			base_img="$2"
			new_mac="$3"
			new_uuid="$4"
			shift 4			
			;;
			
		*)
			echo "Argumento $1 no valido"
			exit 1
			;;
		esac
done

check "$name" "$com"

if [ $way == "individual" ]
then
	execute "$com" "$user" "$ip" "$name" "$path"
elif [ $way == "group" ]
then
	read_conf_file "$name" "$user" "$ip" "$com" "$path"
fi

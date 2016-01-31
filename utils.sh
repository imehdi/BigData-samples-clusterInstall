##!/bin/bash


installSSH()
{
	sudo apt-get install openssh-server
	ssh-keygen -t rsa -P ""
	cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
	echo "SSH CONFIGURED"
}



installSSH_Local()
{
	sudo apt-get install openssh-server
	ssh-keygen -t rsa -P ""
	cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
	echo "SSH CONFIGURED"

	ssh-copy-id -i ~/.ssh/id_rsa.pub slave-1

}


installSSH_copy_to_slave()
{
	. ./cluster_architecture.properties  
	arr=$(echo $slaves | tr "," "\n")

	for x in $arr
	do
	    ssh-copy-id -i ~/.ssh/id_rsa.pub $x
	done

}


addUser()
{
	sudo addgroup hadoop 
	sudo adduser --ingroup hadoop $USER
}


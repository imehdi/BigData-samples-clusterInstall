##!/bin/bash


HDP_HOME=/usr/local/

export M2_HOME=/usr/local/maven
export PATH=${M2_HOME}/bin:${PATH}


##install master 

read -p "add User ? [Y/N] ? " choice

if [[ $choice =~ ^[Yy]$ ]]; then
	. utils.sh
	addUser 
fi



read -p "Install ssh ? [Y/N] ? " choice


echo $choice

if [[ $choice =~ ^[Yy]$ ]]; then
	. utils.sh
	installSSH
	installSSH_copy_to_slave
fi


read -p "Install Hadoop  ? [Y/N]" choice

if [[ $choice =~ ^[Yy]$ ]]; then
##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


read -p "Install Hadoop on Master ? [Y/N]" choice

if [[ $choice =~ ^[Yy]$ ]]; then
		cd $HDP_HOME
		sudo mkdir /usr/local/hadoop		
		read -p "download Hadoop ? [Y/N]" download
		if [[ $download =~ ^[Yy]$ ]]; then
			sudo wget http://apache.crihan.fr/dist/hadoop/common/hadoop-2.6.0/hadoop-2.6.0-src.tar.gz
			sudo tar -xzvf hadoop-2.6.0-src.tar.gz
                	sudo chown hadoop:hadoop -R hadoop-2.6.0-src
			cd hadoop-2.6.0-src		
			sudo apt-get install protobuf-compiler
			mvn package -Pdist -DskipTests -Dtar
			sudo cp -r hadoop-dist/target/hadoop-2.6.0/* /usr/local/hadoop
			sudo chown hadoop:hadoop -R /usr/local/hadoop 
			sudo mkdir -p /usr/local/hadoop_tmp/hdfs/namenode
			sudo mkdir -p /usr/local/hadoop_tmp/hdfs/datanode
			sudo mkdir -p /usr/local/hadoop_tmp/logs
			sudo chown hadoop:hadoop -R /usr/local/hadoop_tmp/ 
		fi
		HADOOP_HOME=/usr/local/hadoop
		sudo chown hadoop:hadoop -R /usr/local/hadoop

fi
##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## install on slaves



read -p "Install Hadoop On slaves ? [Y/N]" choice

if [[ $choice =~ ^[Yy]$ ]]; then
	. ./cluster_architecture.properties  
	arr=$(echo $slaves | tr "," "\n")

	for x in $arr
	do
		read -p "Install Java On slave ? [Y/N]" choice
		if [[ $choice =~ ^[Yy]$ ]]; then
			ssh -t hadoop@$x "sudo apt-get install openjdk-7-jdk"
		fi
		read -p "copy hadoop On slave ? [Y/N]" choice
		if [[ $choice =~ ^[Yy]$ ]]; then
			sudo scp -r /usr/local/hadoop hadoop@$x:~
			ssh -t hadoop@$x "sudo mkdir -p /usr/local/hadoop; sudo cp -r ~/hadoop/* /usr/local/hadoop"
			ssh -t hadoop@$x "sudo chown hadoop:hadoop -R /usr/local/hadoop"
			sudo scp -r /usr/local/hadoop_tmp hadoop@$x:~
			ssh -t hadoop@$x "sudo mkdir -p /usr/local/hadoop_tmp; sudo cp -r ~/hadoop_tmp/* /usr/local/hadoop_tmp"
			ssh -t hadoop@$x "sudo chown hadoop:hadoop -R /usr/local/hadoop_tmp"
		fi
	done
fi

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## CONFIG HADOOP 


read -p "change /etc/hosts ? [Y/N]" update
if [[ $update =~ ^[Yy]$ ]]; then
	sudo cp conf/hosts /etc/hosts
	echo "
192.168.182.130 master
192.168.182.131 slave1 "  | sudo tee --append /etc/hosts

	sudo hostname master

	. ./cluster_architecture.properties  
	arr=$(echo $slaves | tr "," "\n")

	iter=1
	for x in $arr
	do
	sudo scp -r conf hadoop@$x:~
	ssh -t hadoop@$x "sudo cp ~/conf/hosts /etc/hosts"
	ssh -t hadoop@$x "echo \"192.168.182.130 master
192.168.182.131 slave1	\" | sudo tee --append /etc/hosts" 

	ssh -t hadoop@$x "sudo hostname slave$iter "
	iter=$iter+1
	done

fi 



read -p "set/change config hadoop ? [Y/N]" update
if [[ $update =~ ^[Yy]$ ]]; then	
## master-slave
cp conf/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
cp conf/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
cp conf/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml

	. ./cluster_architecture.properties  
	arr=$(echo $slaves | tr "," "\n")

	for x in $arr
	do
	sudo scp -r conf hadoop@$x:~
	ssh -t hadoop@$x "cp ~/conf/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml"
	ssh -t hadoop@$x "cp ~/conf/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml"
	ssh -t hadoop@$x "cp ~/conf/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml"
	done


# master only 
cp conf/mapred-site.xml $HADOOP_HOME/etc/hadoop/mared-site.xml
cp conf/slaves $HADOOP_HOME/etc/hadoop/slaves

fi

read -p "format hdfs ? [Y/N]" format
if [[ $format =~ ^[Yy]$ ]]; then
	rm -Rf /usr/local/hadoop_tmp/hdfs/*
	. ./cluster_architecture.properties  
	arr=$(echo $slaves | tr "," "\n")
	for x in $arr
	do
		ssh -t hadoop@$x "rm -Rf /usr/local/hadoop_tmp/hdfs/*"
	done
	hdfs namenode -format
fi



read -p "update bashrc ? [Y/N]" update
if [[ $update =~ ^[Yy]$ ]]; then	
	echo "export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
	export HADOOP_HOME=/usr/local/hadoop
	export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin	
	export HADOOP_MAPRED_HOME=$HADOOP_HOME
	export HADOOP_COMMON_HOME=$HADOOP_HOME
	export HADOOP_HDFS_HOME=$HADOOP_HOME
	export YARN_HOME=$HADOOP_HOME
	export HADOOP_COMMON_LIB_NATIVE_DIR="$HADOOP_HOME"/lib/native
	export HADOOP_OPTS=\"-Djava.library.path="$HADOOP_HOME"/lib\"" >> ~/.bashrc
	source ~/.bashrc
	
	. ./cluster_architecture.properties  
	arr=$(echo $slaves | tr "," "\n")

	for x in $arr
	do
	ssh -t hadoop@$x "echo \"export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
	export HADOOP_HOME=/usr/local/hadoop
	export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin	
	export HADOOP_MAPRED_HOME=$HADOOP_HOME
	export HADOOP_COMMON_HOME=$HADOOP_HOME
	export HADOOP_HDFS_HOME=$HADOOP_HOME
	export YARN_HOME=$HADOOP_HOME
	export HADOOP_COMMON_LIB_NATIVE_DIR=\"$HADOOP_HOME\"/lib/native
	export HADOOP_OPTS=\"-Djava.library.path="$HADOOP_HOME"/lib\"\" >> ~/.bashrc; source ~/.bashrc"
	done

fi


fi

read -p "start Yarn on cluster ? [Y/N]" update
if [[ $update =~ ^[Yy]$ ]]; then
start-all.sh
mr-jobhistory-daemon.sh start historyserver
fi 

read -p "install hive ? [Y/N]" update
if [[ $update =~ ^[Yy]$ ]]; then

	read -p "dowload hive ? [Y/N]" update
	if [[ $update =~ ^[Yy]$ ]]; then
		cd ~/Downloads/
		sudo wget http://apache.claz.org/hive/stable/apache-hive-1.2.1-bin.tar.gz
		sudo tar -xzvf apache-hive-1.2.1-bin.tar.gz
	fi        	

sudo mkdir /usr/local/hive
sudo cp -r ~/Downloads/apache-hive-1.2.1-bin/* /usr/local/hive


echo "export HIVE_HOME=/usr/local/hive
	export PATH=$PATH:$HIVE_HOME/bin " >> ~/.bashrc
source ~/.bashrc

sudo cp conf/hive/hive-config.sh /usr/local/hive/bin/hive-config.sh

read -p "create JDBC Metastore ? [Y/N]" update
if [[ $update =~ ^[Yy]$ ]]; then
sudo cp /home/hadoop/Desktop/scripts/conf/hive/hive-site.xml /usr/local/hive/conf/hive-site.xml
sudo cp /home/hadoop/Desktop/scripts/conf/hive/mysql-connector-java-5.1.18.jar /usr/local/hive/lib/

fi

read -p "create HDFS HIVE ? [Y/N]" update
if [[ $update =~ ^[Yy]$ ]]; then
hadoop fs -mkdir /usr
hadoop fs -mkdir /usr/hive
hadoop fs -mkdir /usr/hive/warehouse
hadoop fs -chmod g+w /usr/hive/warehouse
fi
fi 

## Apache Sqoop 1.4.6
## Author: mehdi.idoudi@gmail.com
read -p "install apache sqoop ? [Y/N]" update
if [[ $update =~ ^[Yy]$ ]]; then

	read -p "dowload apache sqoop ? [Y/N]" update
	if [[ $update =~ ^[Yy]$ ]]; then
		cd ~/Downloads/
		sudo wget http://apache.claz.org/sqoop/1.4.6/sqoop-1.4.6.bin__hadoop-1.0.0.tar.gz
		sudo tar -xzvf sqoop-1.4.6.bin__hadoop-1.0.0.tar.gz 
		mv sqoop-1.4.6.bin__hadoop-1.0.0.tar.gz /usr/lib/sqoop
		cd /usr/lib/sqoop
		./bin/addtowar.sh -hadoop-auto
		./bin/addtowar.sh -hadoop-version 2.0 -hadoop-path /usr/lib/hadoop-common:/usr/lib/hadoop-hdfs:/usr/lib/hadoop-yarn
	fi        	
fi

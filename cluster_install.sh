##!/bin/bash

HDP_HOME=/usr/local/

export M2_HOME=/usr/local/maven
export PATH=${M2_HOME}/bin:${PATH}

read -p "Install ssh ? [Y/N]" choice

if [[ $choice =~ ^[Yy]$ ]]; then
	. utils.sh
	installSSH 
fi


read -p "add User ? [Y/N]" choice

if [[ $choice =~ ^[Yy]$ ]]; then
	. utils.sh
	addUser 
fi

read -p "Install Hadoop ? [Y/N]" choice

if [[ $choice =~ ^[Yy]$ ]]; then
	cd $HDP_HOME
		echo "export M2_HOME=/usr/local/maven
		export PATH=${M2_HOME}/bin:${PATH}" >> ~/.bashrc
		s 
		read -p "download Hadoop ? [Y/N]" download
		if [[ $download =~ ^[Yy]$ ]]; then
		#sudo wget apache.crihan.fr/dist/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
		#sudo tar -xzvf hadoop-2.6.0.tar.gz
		sudo wget http://apache.crihan.fr/dist/hadoop/common/hadoop-2.6.0/hadoop-2.6.0-src.tar.gz
		
		#sudo gunzip hadoop-2.6.0-src.tar.gz
		sudo tar -xzvf hadoop-2.6.0-src.tar.gz
                sudo chown hadoop:hadoop -R hadoop-2.6.0-src
		cd hadoop-2.6.0-src
		sudo mkdir /usr/local/hadoop
		
		sudo apt-get install protobuf-compiler
		mvn package -Pdist -DskipTests -Dtar
		sudo cp -r hadoop-dist/target/hadoop-2.6.0/* /usr/local/hadoop
		sudo chown hadoop:hadoop -R /usr/local/hadoop 
		sudo mkdir -p /usr/local/hadoop_tmp/hdfs/namenode
		sudo mkdir -p /usr/local/hadoop_tmp/hdfs/datanode
		sudo chown hadoop:hadoop -R /usr/local/hadoop_tmp/ 
		fi
		#sudo mv hadoop-2.6.0 /usr/local/hadoop 
		HADOOP_HOME=/usr/local/hadoop
		sudo chown hadoop:hadoop -R /usr/local/hadoop
	
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
	fi
	s
	read -p "config hadoop ? [Y/N]" config
	if [[ $config =~ ^[Yy]$ ]]; then

	cd $HADOOP_HOME/etc/hadoop
	sudo echo "JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64" >> hadoop-env.sh

	sudo echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?> 
<configuration>
	<property>
		<name>fs.default.name</name>
		<value>hdfs://localhost:9000</value>
	</property>
</configuration>" > core-site.xml

	sudo echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?> 
<configuration>
	<property>
	      <name>dfs.replication</name>
	      <value>1</value>
	 </property>
	 <property>
	      <name>dfs.namenode.name.dir</name>
	      <value>file:/usr/local/hadoop_tmp/hdfs/namenode</value>
	 </property>
	 <property>
	      <name>dfs.datanode.data.dir</name>
	      <value>file:/usr/local/hadoop_tmp/hdfs/datanode</value>
	 </property>
</configuration>"  > hdfs-site.xml
	
	sudo echo "<?xml version=\"1.0\"?> 
<configuration>
	<property>
	      <name>yarn.nodemanager.aux-services</name>
	      <value>mapreduce_shuffle</value>
	</property>
	<property>
	      <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
	      <value>org.apache.hadoop.mapred.ShuffleHandler</value>
	</property>
</configuration>" > yarn-site.xml
		 
	#cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template  /usr/local/hadoop/etc/hadoop/mapred-site.xml
	sudo echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?> 
<configuration>
	<property>
	      <name>mapreduce.framework.name</name>
	      <value>yarn</value>
	</property>
</configuration>" > mapred-site.xml
	
	fi
	read -p "format hdfs ? [Y/N]" format
	if [[ $format =~ ^[Yy]$ ]]; then
		hdfs namenode -format
	fi

else
     quit	
fi




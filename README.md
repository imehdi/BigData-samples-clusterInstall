# BigData-samples-clusterInstall

Shell scripts to install a small hadoop cluster with 2 nodes



##Prerequisites:
* Os: Ubuntu 
* 2 nodes : 1 master+slave, 1 slave
* Install java 1.7 on master and slave: sudo apt-get install openjdk-7-jdk
* In slave, before launching the scipt:
  *  sudo visudo
  *  Edit sudoers 
    * Just under the line that looks like the following:
        root ALL=(ALL) ALL
    *  add
        hadoop  ALL=(ALL:ALL) ALL
    *  Save File

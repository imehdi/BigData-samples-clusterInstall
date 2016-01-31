##!/bin/bash


HDP_HOME=/usr/local/
export M2_HOME=/usr/local/maven
export PATH=${M2_HOME}/bin:${PATH}

. utils.sh
addUser 
installSSH


Open a Root Terminal and type visudo (to access and edit the list).

Navigate to the bottom of the sudoers file that is now displayed in the terminal.

Just under the line that looks like the following:

    root ALL=(ALL) ALL

Add the following (replacing user with your actual username):

    user ALL=(ALL) ALL


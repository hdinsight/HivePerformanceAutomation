#!/bin/bash

set -x
sudo apt-get --yes install git

which sshpass &> /dev/null || sudo apt-get -y -qq install sshpass
which pdsh &> /dev/null || sudo apt-get -y -qq install pdsh

if [ ! -d "${OUTPUT_PATH}/azlogs" ]; then
	git clone https://github.com/dharmeshkakadia/azlogs ${OUTPUT_PATH} ;
    {CURRENT_DIRECTORY}/apache-maven-3.0.5/bin/mvn package assembly:single -f ${OUTPUT_PATH}/azlogs/pom.xml;
fi

which csvsql > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Installing CSVKIT" 
	# 3.5 cluster ships with older version of pip which fails the package install
	pip install --upgrade pip
	sudo pip install csvkit
fi

for slave in `cat /etc/hadoop/conf/slaves`
do
        #echo "ssh-copy-id on $slave"
        sshpass -p $1 ssh-copy-id -o StrictHostKeyChecking=no ${slave}
done

pdsh -R ssh -w ^/etc/hadoop/conf/slaves sudo apt-get -y -qq install linux-tools-common sysstat gawk

if [ ! -d ${OUTPUT_PATH}/PAT-master ]; then
        echo "Downloading PAT tool"
		git clone https://github.com/dharmeshkakadia/PAT-fork.git
        mkdir -p ${OUTPUT_PATH}/PAT-master/
	mv  PAT-fork/* ${OUTPUT_PATH}/PAT-master/
	sudo rm -r PAT-fork/
fi

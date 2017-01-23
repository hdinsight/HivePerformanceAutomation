#!/bin/bash

set -x
sudo apt-get --yes install git

# Check if Maven is installed and install it if not.
which mvn > /dev/null 2>&1
if [ $? -ne 0 ]; then
	SKIP=0
	if [ -e "apache-maven-3.0.5-bin.tar.gz" ]; then
		SIZE=`du -b apache-maven-3.0.5-bin.tar.gz | cut -f 1`
		if [ ${SIZE} -eq 5144659 ]; then
			SKIP=1
		fi
	fi
	if [ ${SKIP} -ne 1 ]; then
		echo "Maven not found, automatically installing it."
		curl -o ${CURRENT_DIR}/apache-maven-3.0.5-bin.tar.gz http://www.us.apache.org/dist/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz  2> /dev/null
		if [ $? -ne 0 ]; then
			echo "Failed to download Maven, check Internet connectivity and try again."
			exit 1
		fi
	fi
	tar -zxf ${CURRENT_DIR}/apache-maven-3.0.5-bin.tar.gz -C ${CURRENT_DIR} > /dev/null
fi

which sshpass &> /dev/null || sudo apt-get -y -qq install sshpass
which pdsh &> /dev/null || sudo apt-get -y -qq install pdsh

which csvsql > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Installing CSVKIT" 
	# 3.5 cluster ships with older version of pip which fails the package install
	pip install --upgrade pip
	sudo pip install csvkit
fi

if [ ! -d "${OUTPUT_PATH}/azlogs" ]; then
	git clone https://github.com/dharmeshkakadia/azlogs ${OUTPUT_PATH}/azlogs ;
    {CURRENT_DIR}/apache-maven-3.0.5/bin/mvn package assembly:single -f ${OUTPUT_PATH}/azlogs/pom.xml;
fi

pdsh -R ssh -w ^/etc/hadoop/conf/slaves sudo apt-get -y -qq install linux-tools-common sysstat gawk

if [ ! -d ${OUTPUT_PATH}/PAT-master ]; then
        echo "Downloading PAT tool"
		git clone https://github.com/dharmeshkakadia/PAT-fork.git
        mkdir -p ${OUTPUT_PATH}/PAT-master/
	mv  PAT-fork/* ${OUTPUT_PATH}/PAT-master/
	sudo rm -r PAT-fork/
fi

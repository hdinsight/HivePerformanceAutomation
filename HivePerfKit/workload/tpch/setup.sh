#!/bin/bash

set -x
sudo apt-get --yes install git

. ./config.sh
#check java
for f in gcc javac; do
	which $f > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Required program $f is missing. Please install or fix your path and try again."
		exit 1
	fi
done

# Check if Maven is installed and install it if not.
which mvn > /dev/null 2>&1
if [ $? -ne 0 ]; then
	SKIP=0
	if [ -e "apache-maven-3.0.5-bin.tar.gz" ]; then
		SIZE=`du -b apache-maven-3.0.5-bin.tar.gz | cut -f 1`
		if [ $SIZE -eq 5144659 ]; then
			SKIP=1
		fi
	fi
	if [ $SKIP -ne 1 ]; then
		echo "Maven not found, automatically installing it."
		curl -o $CURRENT_DIRECTORY/apache-maven-3.0.5-bin.tar.gz http://www.us.apache.org/dist/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz  2> /dev/null
		if [ $? -ne 0 ]; then
			echo "Failed to download Maven, check Internet connectivity and try again."
			exit 1
		fi
	fi
	tar -zxf $CURRENT_DIRECTORY/apache-maven-3.0.5-bin.tar.gz -C $CURRENT_DIRECTORY > /dev/null
fi

which sshpass &> /dev/null || sudo apt-get -y -qq install sshpass
which pdsh &> /dev/null || sudo apt-get -y -qq install pdsh


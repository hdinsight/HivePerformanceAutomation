#!/bin/bash
#Script Usage : ./RunTpch.sh SCALE_FACTOR CLUSTER_SSH_PASSWORD [REPEAT_COUNT]

if [ $# -lt 2 ]
then
	echo "Usage: ./RunTPCH SCALE_FACTOR CLUSTER_SSH_PASSWORD [REPEAT_COUNT]"
	exit 1
fi

TARGET_DIR=hive-testbench
sudo apt-get install git

if [ ! -d "$TARGET_DIR" ]; then
	git clone https://github.com/hdinsight/HivePerformanceAutomation.git $TARGET_DIR
else
	echo "Test bench already downloaded..."
fi

chmod 777 -R $TARGET_DIR

cd $TARGET_DIR

./tpch-build.sh

./tpch-setup.sh $1

cd ./tpch-scripts

echo "Running TPCH Queries and Collecting PAT Data"

if [ -z "$3" ]; then
	./RunSuiteLoop.sh $3 $1 $2
else
	./RunSuiteLoop.sh 1 $1 $2
fi

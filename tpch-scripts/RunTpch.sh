#!/bin/bash
#Script Usage : ./RunTpch.sh SCALE_FACTOR CLUSTER_SSH_PASSWORD

if [ $# -ne 2 ]
then
	echo "Usage: ./RunTPCH SCALE_FACTOR CLUSTER_SSH_PASSWORD"
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

./RunQueriesAndCollectPATData.sh $1 $2

echo "collecting perf data in the background"
./CollectPerfData.sh > ../CollectPerfData.log 2>&1 &

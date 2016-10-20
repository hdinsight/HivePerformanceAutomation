#!/bin/bash

wget -O /tmp/HDInsightUtilities-v01.sh -q https://hdiconfigactions.blob.core.windows.net/linuxconfigactionmodulev01/HDInsightUtilities-v01.sh && source /tmp/HDInsightUtilities-v01.sh && rm -f /tmp/HDInsightUtilities-v01.sh

if [[ `hostname -f` == `get_primary_headnode` ]]; then
	cd $1
	wget https://github.com/hdinsight/HivePerformanceAutomation/archive/master.zip
	unzip master.zip;
fi

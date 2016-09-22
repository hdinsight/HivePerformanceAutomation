#!/bin/bash
BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd );
BENCHMARK=hive-testbench

if [ $# -eq 0 ]
then
	echo "Usage ./GetATSDAG.sh PERFDATA_OUTPUTDIR"
	echo "Default Values will be used if you do not provide command line parameters"
fi

if [ -z $1 ]
then
	PERFDATA_OUTPUTDIR=$BENCH_HOME/$BENCHMARK/PerfData/
else
	PERFDATA_OUTPUTDIR=$1
fi

echo "PERFDATA_OUTPUTDIR is set to $PERFDATA_OUTPUTDIR"

mkdir ${PERFDATA_OUTPUTDIR}/ATSDATA

while read -r line
do
        echo "Getting history zip data for $line"
		read -a linearray <<< $line
		hadoop jar /usr/hdp/current/tez-client/tez-history-parser*.jar org.apache.tez.history.ATSImportTool -dagId ${linearray[0]}  --downloadDir $PERFDATA_OUTPUTDIR/${linearray[1]}
done <  ${PERFDATA_OUTPUTDIR}/dagids.txt
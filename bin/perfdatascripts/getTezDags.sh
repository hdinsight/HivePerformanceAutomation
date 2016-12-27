#!/bin/bash
if [ $# -eq 0 ]
then
	echo "Usage ./GetTezDags.sh RESULTS_DIR PERFDATA_OUTPUTDIR TIMELINE_SERVER"
	echo "Default Values will be used if you do not provide command line parameters"
fi

if [ ! -z $1 ]
then
        RESULTS_DIR=$1
fi

if [ ! -z $2 ]
then
        PERFDATA_OUTPUTDIR=$2
fi

if [ ! -z $3 ]
then
        TIMELINE_SERVER=$3
fi

set -x

echo "RESULTS_DIR is set to $RESULTS_DIR"
echo "PERFDATA_OUTPUTDIR is set to $PERFDATA_OUTPUTDIR"
echo "TIMELINE_SERVER is set to $TIMELINE_SERVER"

file="$PERFDATA_OUTPUTDIR/appids.txt"
count=01
mkdir $PERFDATA_OUTPUTDIR/dags
rm $PERFDATA_OUTPUTDIR/dags/*
while read -r line
do
        echo "Getting dag for $line"
        read -a linearray <<< $line
        curl  $TIMELINE_SERVER/TEZ_DAG_ID?primaryFilter=applicationId:${linearray[0]} > $PERFDATA_OUTPUTDIR/dags/dag_${linearray[1]}.txt
done < $file


#!/bin/bash
if [ $# -eq 0 ]
then
	echo "Usage ./GetTezApplication.sh RESULTS_DIR PERFDATA_OUTPUTDIR TIMELINE_SERVER"
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

echo "RESULTS_DIR is set to $RESULTS_DIR"
echo "PERFDATA_OUTPUTDIR is set to $PERFDATA_OUTPUTDIR"
echo "TIMELINE_SERVER is set to $TIMELINE_SERVER"

file="$PERFDATA_OUTPUTDIR/dagids.txt"
mkdir $PERFDATA_OUTPUTDIR/tezapplication
rm $PERFDATA_OUTPUTDIR/tezapplication/*

while read -r line
do
        echo "Getting TEZ_APPLICATION for $line"
		read -a linearray <<< $line
		outfilename="${linearray[1]/dag/tez_application}"
		dagid=${linearray[0]}
		tezapplicationid=${dagid/dag/tez_application}
		tezapplicationid=${tezapplicationid:0:-2}
		echo "Tez application id is $tezapplicationid"
        curl  $TIMELINE_SERVER/TEZ_APPLICATION/$tezapplicationid > $PERFDATA_OUTPUTDIR/tezapplication/$outfilename.txt
done < $file


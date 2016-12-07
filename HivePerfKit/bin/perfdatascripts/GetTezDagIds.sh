#!/bin/bash

if [ $# -eq 0 ]
then
	echo "Usage ./GetTezDagIds.sh RESULTS_DIR PERFDATA_OUTPUTDIR TIMELINE_SERVER"
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

mkdir $PERFDATA_OUTPUTDIR
		
>$PERFDATA_OUTPUTDIR/dagids.txt

for file in $PERFDATA_OUTPUTDIR/dags/*.txt
do
	grep -P -o '"dag_.*?"' "$file" | tr -d '\n' >> $PERFDATA_OUTPUTDIR/dagids.txt
	filebase=${file##*/}
	filename=${filebase%.*}

	echo -e "\t$filename" >> $PERFDATA_OUTPUTDIR/dagids.txt
done
    sed -i 's/\"//g' $PERFDATA_OUTPUTDIR/dagids.txt


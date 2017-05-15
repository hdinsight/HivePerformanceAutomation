#/bin/bash

function usageerror {
	echo "please enter scale factor in the config"
	exit 1
}

function runcommand {
	if [ "X$DEBUG_SCRIPT" != "X" ]; then
		$1
	else
		$1 2>/dev/null
	fi
}

set -x
. ./config.sh
cd ${CURRENT_DIRECTORY}
echo "Building TPC-H Data Generator"
(cd tpch-gen; make)
echo "TPC-H Data Generator built, you can now use tpch-setup.sh to generate data."

if [ ! -f tpch-gen/target/tpch-gen-1.0-SNAPSHOT.jar ]; then
	echo "Please build the data generator with ./tpch-build.sh first"
	exit 1
fi
which hive > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Script must be run where Hive is installed"
	exit 1
fi

DIR=$RAWDATA_DIR

if [ "X$DEBUG_SCRIPT" != "X" ]; then
	set -x
fi

# Sanity checking.
if [ X"$SCALE" = "X" ]; then
	usageerror
fi

if [ X"$DIR" = "X" ]; then
	DIR=/tmp/tpch-generate
fi

if [ $SCALE -lt 2 ]; then
	echo "Scale factor must be greater than 1"
	exit 1
fi

mkdir -p $LOADTIMES_DIR
touch $LOADTIMES_FILE

STARTTIME="`date +%s`"
# Do the actual data load.
hdfs dfs -mkdir -p ${DIR}
hdfs dfs -ls ${DIR}/${SCALE}/lineitem > /dev/null
if [ $? -ne 0 ]; then
	echo "Generating data at scale factor $SCALE."
	(cd tpch-gen; hadoop jar target/*.jar -d ${DIR}/${SCALE}/ -s ${SCALE})
fi
hdfs dfs -ls ${DIR}/${SCALE}/lineitem > /dev/null
if [ $? -ne 0 ]; then
	echo "Data generation failed, exiting."
	exit 1
fi
echo "TPC-H text data generation complete."

hdfs dfs -ls ${WAREHOUSE_DIR}/tpch_partitioned_orc_${SCALE}.db > /dev/null

if [ $? -eq 0 ]; then
	echo "Data already loaded into query tables"
	exit 1
fi
	
DATAGENTIME="`date +%s`" 

echo "DATAGENTIME,$( expr $DATAGENTIME - $STARTTIME)" >> $LOADTIMES_FILE

BEELINE_CONNECTION_STRING=$CONNECTION_STRING/$RAWDATA_DATABASE";transportMode=http"
# Create the text/flat tables as external tables. These will be later be converted to ORCFile.
echo "Loading text data into external tables."
runcommand "beeline -u ${BEELINE_CONNECTION_STRING} -i settings/load-flat.sql -f ${CURRENT_DIRECTORY}/ddl-tpch/bin_partitioned/allexternaltables.sql --hivevar DB=${RAWDATA_DATABASE} --hivevar LOCATION=${DIR}/${SCALE}"

EXTERNALTABLELOAD="`date +%s`" 
# Create the optimized tables.
echo "EXTERNALTABLELOAD,$( expr $EXTERNALTABLELOAD - $DATAGENTIME)" >> $LOADTIMES_FILE
i=1
total=8

BEELINE_CONNECTION_STRING=$CONNECTION_STRING/$QUERY_DATABASE";transportMode=http"

for t in ${TABLES}
do
	echo "Optimizing table $t ($i/$total)."
	TABLELOADSTART="`date +%s`"	
	COMMAND="beeline -u ${BEELINE_CONNECTION_STRING} -i ${CURRENT_DIRECTORY}/ddl-tpch/load-partitioned.sql -f ${CURRENT_DIRECTORY}/ddl-tpch/bin_partitioned/${t}.sql \
	    --hivevar DB=${QUERY_DATABASE} \
	    --hivevar SOURCE=${RAWDATA_DATABASE}
            --hivevar SCALE=${SCALE} \
	    --hivevar FILE=orc"
	runcommand "$COMMAND"
	TABLELOADEND="`date +%s`"

	echo "TABLELOAD_${t},$( expr $TABLELOADEND - $TABLELOADSTART)" >> $LOADTIMES_FILE
	if [ $? -ne 0 ]; then
		echo "Command failed, try 'export DEBUG_SCRIPT=ON' and re-running"
		exit 1
	fi
	i=`expr $i + 1`
done

echo "Data loaded into ${QUERY_DATABASE}"

ORCLOAD="`date +%s`"

ANALYZE_COMMAND="beeline -u ${BEELINE_CONNECTION_STRING} -i ${CURRENT_DIRECTORY}/settings/load-partitioned.sql \
	    --hivevar DB=${QUERY_DATABASE} \
		-f ${CURRENT_DIRECTORY}/ddl-tpch/bin_partitioned/analyze.sql"

if $RUN_ANALYZE; then
	echo "Running analyze"
	runcommand "$ANALYZE_COMMAND"
fi

ANALYZETIME="`date +%s`"

echo "ANALYZETIME, $( expr $ANALYZETIME - $ORCLOAD)" >> $LOADTIMES_FILE
echo "Analyze completed"

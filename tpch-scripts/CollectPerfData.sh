#!/bin/bash
export BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd );
echo "\$BENCH_HOME is set to $BENCH_HOME";

export BENCHMARK=hive-testbench

if [ $# -eq 0 ]
then
	echo "Usage ./CollectPerfData.sh RUN_ID RESULTS_DIR PERFDATA_OUTPUTDIR SERVER"
	echo "Default Values will be used if you do not provide command line parameters. RUN_ID is mandatory"
fi

if [ -z $1 ]
then
	echo "Please enter RUN_ID"
	exit 1
else
	RUN_ID=$1
fi

if [ -z $2 ]
then
	RESULTS_DIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/results/
else
	RESULTS_DIR=$2
fi

if [ -z $3 ]
then
	PERFDATA_OUTPUTDIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/PerfData/
else
	PERFDATA_OUTPUTDIR=$3
fi

if [ -z $4 ]
then
	SERVER=http://headnodehost:8188/ws/v1/timeline
else
	SERVER=$4
fi

echo "RESULTS_DIR is set to $RESULTS_DIR"
echo "PERFDATA_OUTPUTDIR is set to $PERFDATA_OUTPUTDIR"
echo "SERVER is set to $SERVER"
echo "Running Scripts for Perf Data Collection ..."

mkdir $PERFDATA_OUTPUTDIR

./GetHiveQueryIds.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER

./GetTezDagsIds.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER

./GetATSDAG.sh $PERFDATA_OUTPUTDIR

./getStoreLatency.sh ${BENCH_HOME}/${BENCHMARK}/run_$RUN_ID/logs/query_times.csv $PERFDATA_OUTPUTDIR

./getTaskNodeAssignment.sh $PERFDATA_OUTPUTDIR $PERFDATA_OUTPUTDIR/nodetasks.csv

./getCounters.sh $PERFDATA_OUTPUTDIR $PERFDATA_OUTPUTDIR/dag_counters.csv

cp -R $BENCH_HOME/$BENCHMARK/tpch-scripts/PAT-master/PAT/results/$RUN_ID $PERFDATA_OUTPUTDIR/pat

./getPATSummary.sh $PERFDATA_OUTPUTDIR/pat $PERFDATA_OUTPUTDIR 

sudo csvsql ${BENCH_HOME}/${BENCHMARK}/run_$RUN_ID/logs/query_times.csv $PERFDATA_OUTPUTDIR/node_report.csv $PERFDATA_OUTPUTDIR/dag_counters.csv $PERFDATA_OUTPUTDIR/latency_summary.csv --query "select node_report.query,STATUS,DURATION_IN_SECONDS,TOTAL_LAUNCHED_TASKS, NUM_SUCCEEDED_TASKS,NUM_KILLED_TASKS,NUM_FAILED_TASKS,avg(avg_user_cpu),avg(avg_sys_cpu),avg(avg_iowait),max(max_user_cpu),max(max_sys_cpu),max(max_iowait),WASB_BYTES_READ/1000000000,size_GB,total_count total_request_count,sucessful_count sucessful_request_count,throttelled_count throttelled_request_count, E2E99th,E2E999th,E2E_avg,E2E_max,E2E_server_avg,E2E_server_max,avg(net_avg_rxmBs),avg(net_avg_txmBs),max(net_max_rxmBs),max(net_max_txmBs),FILE_BYTES_READ,FILE_BYTES_WRITTEN,avg(io_avg_overload),avg(io_avg_rmBs),avg(io_avg_wmBs),avg(io_avg_avgqusz),avg(io_avg_await),avg(avg_svctm),max(io_max_rkBs),max(io_max_wkBs),max(io_max_avgqusz),max(io_max_await),max(io_max_svctm),avg(io_avg_util),sum(io_sum_rkBs),sum(io_sum_wkBs),sum(io_sum_await),sum(io_sum_svctm) from query_times, node_report,dag_counters, latency_summary where lower(query_times.query)=node_report.query and dag_counters.query=node_report.query and lower(latency_summary.query)=node_report.query group by node_report.query" > $PERFDATA_OUTPUTDIR/run_$RUN_ID_summary.csv
echo "Completed Running PerfData Collection Scripts"

zip -r $BENCH_HOME/$BENCHMARK/run_$RUN_ID/PerfData.zip $PERFDATA_OUTPUTDIR

echo "zipped Perfdata to $BENCH_HOME/$BENCHMARK/run_$RUN_ID/PerfData.zip"

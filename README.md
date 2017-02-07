Hive Perf Automation Kit
========================
This kit can be used to run benchmarks/custom workloads and collect system/hiveapplication data in a fully automated manner

Steps to set up a custom workload
=================================
Put your workload specific files in the workload/${WORKLOAD_NAME}/ folder
This folder should contain the following files
1)setup.sh - install pre-requisites for the workload. for ex: git, maven etc
2)prerun.sh - The logic to generate and load the data into the query databases
3)settings.sql - contains the hive settings with which the workload queries are executed
	For ex: hive.stats.autogather=false;
4)queries/ : put your queries inside this folder. The queries are picked up automatically and executed by the engine
5)config.sh : Define all the workload specific configs here. for ex: SCALE=1000 (for tpch). The config should definitely define
  QUERY_DATABASE which is the database on which the queries are executed.

Steps to Run a workload
========================
1)Set the parameters in the globalconfig.sh files

The below parameters need to be set appropriately
CONNECTION_STRING=jdbc:hive2://localhost:10001
CLUSTER_SSH_PASSWORD=H@doop1234

2) If you want to skip any operation like prerun, patdatacollection, perfdatacollection. Set the flags appropriately in the globalconfig.sh files

3) From the bin directory issue the following command to set execution priviliges on the scripts:

chmod o+x *.sh ; chmod o+x perfdatascripts/*.sh

4) Now from the bin directory run the following command to execute the workload:

./runWorkload WORKLOAD_NAME [REPEAT_COUNT]

WORKLOAD_NAME:should match the folder name in the workload folder
REPEAT_COUNT: an optional argument to specify how many times a workload needs to be executed. Default value is 1.

5) If you want to only run queries and skip the dataload/prerun phase. You can do either of the following
	a)set the SKIP_PRERUN flag to true in the globalconfig.sh file and run 
		./runWorkload WORKLOAD_NAME [REPEAT_COUNT]
		
		OR
	
	b)./runQueries WORKLOAD_NAME [REPEAT_COUNT]
	
6) if you want to execute a single query in a workload n times 
	./runSingleQueryLoop.sh WORKLOAD_NAME FILENAME
	give the full filename along with the extension. for ex:
	./runSingleQueryLoop.sh tpch tpch_query1.sql

Perfdata collection
========================

The perf data output is stored in the following folder

/output/$WORKLOAD_NAME/run_$RUNID/PerfData_$RUN_ID.zip
$RUN_ID is the start timestamp of the workload execution.

The Perfdata contains the following folders
1)querytimes/ : contains the query execution times
2)results/ : The beeline logs for the query execution and the resultsets.
3)plans/ : The query execution plans/
4)perfdata/ : Contains the PAT data (network,IO,cpu etc), the storage logging data and the ATS DAG data.

hive-testbench
==============

A testbench for experimenting with Apache Hive at any data scale. You can deploy to azure using :
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhdinsight%2FHivePerformanceAutomation%2Fmaster%2Fazure%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Kickoff
=======
* You can kickoff the 10 iterations of 1 TB run with

``curl https://raw.githubusercontent.com/hdinsight/HivePerformanceAutomation/master/tpch-scripts/RunTpch.sh | bash -s -- 1000 PASSWORD 10 ``

* You can run one iteration of the suite from the headnode of your cluster by running the following command from hive-testbench/tpch-scripts

``./RunQueriesAndCollectPATData.sh SCALE_FACTOR CLUSTER_SSH_PASSWORD [RUN_ID]``
RUN_ID is an optional argument. All the data for a run is collected under the hive-testbench/run_$RUN_ID folder. If the RUN_ID is not supplied then the current timestamp is used as the runId.

* You can run multiple iterations of the suite from the headnode of your cluster the following command from hive-testbench/tpch-scripts

``./RunSuiteLoop REPEAT_COUNT SCALE_FACTOR CLUSTER_SSH_PASSWORD``
for ex: ./RunSuiteLoop 10 1000 H@doop1234
would run 10 iterations of the TPCH suite for a scale factor of 1000 (1GB)

* You can Run a Single Query from the headnode of your cluster by running the following command from hive-testbench/tpch-scripts

``./TpchQueryExecute.sh SCALE_FACTOR QUERY_NUMBER [RUN_ID]``

* You can run multiple iterations of a single query by running the following command from hive-testbench/tpch-scripts

``./RunSingleQueryLoop QUERY_NUMBER REPEAT_COUNT SCALCE_FACTOR CLUSTER_SSH_PASSWORD``

* you can run the following script from hive-testbench/tpch-scripts to get the perf data collected for a run 

 ``./CollectPerfData.sh RUN_ID [RESULTS_DIR] [PERFDATA_OUTPUTDIR] [SERVER]``
RUN_ID is the id of the run for which you want to collect perfdata

Overview
========

The hive-testbench is a data generator and set of queries that lets you experiment with Apache Hive at scale. The testbench allows you to experience base Hive performance on large datasets, and gives an easy way to see the impact of Hive tuning parameters and advanced settings.

Prerequisites
=============

You will need:
* Hadoop 2.2 or later cluster or Sandbox.
* Apache Hive.
* Between 15 minutes and 2 days to generate data (depending on the Scale Factor you choose and available hardware).
* If you plan to generate 1TB or more of data, using Apache Hive 13+ to generate the data is STRONGLY suggested.

Install and Setup
=================

All of these steps should be carried out on your Hadoop cluster.

- Step 1: Prepare your environment.

  In addition to Hadoop and Hive, before you begin ensure ```gcc``` is installed and available on your system path. If you system does not have it, install it using yum or apt-get.

- Step 2: Decide which test suite(s) you want to use.

  hive-testbench comes with data generators and sample queries based on both the TPC-DS and TPC-H benchmarks. You can choose to use either or both of these benchmarks for experiementation. More information about these benchmarks can be found at the Transaction Processing Council homepage.

- Step 3: Compile and package the appropriate data generator.

  For TPC-DS, ```./tpcds-build.sh``` downloads, compiles and packages the TPC-DS data generator.
  For TPC-H, ```./tpch-build.sh``` downloads, compiles and packages the TPC-H data generator.

- Step 4: Decide how much data you want to generate.

  You need to decide on a "Scale Factor" which represents how much data you will generate. Scale Factor roughly translates to gigabytes, so a Scale Factor of 100 is about 100 gigabytes and one terabyte is Scale Factor 1000. Decide how much data you want and keep it in mind for the next step. If you have a cluster of 4-10 nodes or just want to experiment at a smaller scale, scale 1000 (1 TB) of data is a good starting point. If you have a large cluster, you may want to choose Scale 10000 (10 TB) or more. The notion of scale factor is similar between TPC-DS and TPC-H.

  If you want to generate a large amount of data, you should use Hive 13 or later. Hive 13 introduced an optimization that allows far more scalable data partitioning. Hive 12 and lower will likely crash if you generate more than a few hundred GB of data and tuning around the problem is difficult. You can generate text or RCFile data in Hive 13 and use it in multiple versions of Hive.

- Step 5: Generate and load the data.

  The scripts ```tpcds-setup.sh``` and ```tpch-setup.sh``` generate and load data for TPC-DS and TPC-H, respectively. General usage is ```tpcds-setup.sh scale_factor [directory]``` or ```tpch-setup.sh scale_factor [directory]```

  Some examples:

  Build 1 TB of TPC-DS data: ```./tpcds-setup 1000```

  Build 1 TB of TPC-H data: ```./tpch-setup 1000```

  Build 100 TB of TPC-DS data: ```./tpcds-setup 100000```

  Build 30 TB of text formatted TPC-DS data: ```FORMAT=textfile ./tpcds-setup 30000```

  Build 30 TB of RCFile formatted TPC-DS data: ```FORMAT=rcfile ./tpcds-setup 30000```
  
  Also check other parameters in setup scripts important one is BUCKET_DATA.

- Step 6: Run queries.

  More than 50 sample TPC-DS queries and all TPC-H queries are included for you to try. You can use ```hive```, ```beeline``` or the SQL tool of your choice. The testbench also includes a set of suggested settings.

  This example assumes you have generated 1 TB of TPC-DS data during Step 5:

  	```
  	cd sample-queries-tpcds
  	hive -i testbench.settings
  	hive> use tpcds_bin_partitioned_orc_1000;
  	hive> source query55.sql;
  	```

  Note that the database is named based on the Data Scale chosen in step 3. At Data Scale 10000, your database will be named tpcds_bin_partitioned_orc_10000. At Data Scale 1000 it would be named tpch_flat_orc_1000. You can always ```show databases``` to get a list of available databases.

  Similarly, if you generated 1 TB of TPC-H data during Step 5:

  	```
  	cd sample-queries-tpch
  	hive -i testbench.settings
  	hive> use tpch_flat_orc_1000;
  	hive> source tpch_query1.sql;
  	```

Feedback
========

If you have questions, comments or problems, visit the [Hortonworks Hive forum](http://hortonworks.com/community/forums/forum/hive/).

If you have improvements, pull requests are accepted.

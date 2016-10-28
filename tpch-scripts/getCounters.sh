fields="TOTAL_LAUNCHED_TASKS,RACK_LOCAL_TASKS,DATA_LOCAL_TASKS,NUM_SUCCEEDED_TASKS,NUM_KILLED_TASKS,NUM_FAILED_TASKS,WASB_BYTES_READ,FILE_BYTES_READ,HDFS_BYTES_WRITTEN,WASB_BYTES_WRITTEN,FILE_BYTES_WRITTEN,HDFS_BYTES_WRITTEN"
echo "QUERY,$fields" >$2;

function getcountervalues {
        for i in ${fields//,/ }; do
            s+=','
            s+=$(grep -h1 "$i" <(zcat $1 2> /dev/null)| grep -oP [0-9]+)
        done
        echo "${s}" >> $2
}

while IFS= read -r -d $'\0' file; do
        s=$(echo $file | grep -oP "query[0-9]{2}")
        getcountervalues $file $2
done < <(find $1 -name "*.zip" -type f -print0)

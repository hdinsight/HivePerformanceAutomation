echo "query,operation_type,request_status,count,size,E2E_avg,E2E99th,E2E999th,E2E999th,E2E_min,E2E_max,E2E_server_avg,E2E_server_min,E2E_server_max" > latency_report.csv ;

while read start <&3 && read end <&4 && read query <&5 ; do
	if [[ "$query" = "QUERY" ]] ; then
	continue ;
	fi ;

	echo "Processing $query" ;

	java -jar ../azlogs.jar $(grep -o "fs.azure.account.key\\..*blob.core.windows.net" /etc/hadoop/conf/core-site.xml | sed 's/fs.azure.account.key.//g' | sed 's/.blob.core.windows.net//g') $(/usr/lib/python2.7/dist-packages/hdinsight_common/decrypt.sh $(grep -n2 "fs.azure.account.key\\." /etc/hadoop/conf/core-site.xml | grep -o "<value>.*/value>" | sed 's:<value>::g' | sed 's:</value>::g')) "$start" "$end" "" 2> /dev/null |

	sed '1d' |

	{ echo "version_number;request_start_time;operation_type;request_status;http_status_code;end_to_end_latency_in_ms;server_latency_in_ms;authentication_type;requester_account_name;owner_account_name;service_type;request_url;requested_object_key;request_id_header;operation_count;requester_ip_address;request_version_header;request_header_size;request_packet_size;response_header_size;response_packet_size;request_content_length;request_md5;server_md5;etag_identifier;last_modified_time;conditions_used;user_agent_header;referrer_header;client_request_id"; cat - ; } |

	sudo csvcut -d ";" -c operation_type,request_status,end_to_end_latency_in_ms,server_latency_in_ms,response_packet_size > temp.csv ;

	cat temp.csv | sudo csvsql --query "select '$query' query, operation_type, request_status, count(*) count, sum(response_packet_size) size, avg(end_to_end_latency_in_ms) E2E_avg, min(end_to_end_latency_in_ms) E2E_min, max(end_to_end_latency_in_ms) E2E_max, avg(server_latency_in_ms) E2E_server_avg, min(server_latency_in_ms) E2E_server_min,max(server_latency_in_ms) E2E_server_max from stdin group by request_status,operation_type" > summary ;

	cat temp.csv | sudo csvsql  --query "select max(end_to_end_latency_in_ms) E2E99th,operation_type,request_status from (select end_to_end_latency_in_ms,operation_type,request_status from stdin order by end_to_end_latency_in_ms asc  limit cast(0.99*(select count(end_to_end_latency_in_ms) from stdin)as int)) group by operation_type,request_status" > tmp99 ;

	cat temp.csv | sudo csvsql  --query "select max(end_to_end_latency_in_ms) E2E999th,operation_type,request_status from (select end_to_end_latency_in_ms,operation_type,request_status from stdin order by end_to_end_latency_in_ms asc  limit cast(0.999*(select count(end_to_end_latency_in_ms) from stdin)as int)) group by operation_type,request_status" > tmp999 ;

	cat temp.csv | sudo csvsql  --query "select max(end_to_end_latency_in_ms) E2E9999th,operation_type,request_status from (select end_to_end_latency_in_ms,operation_type,request_status from stdin order by end_to_end_latency_in_ms asc  limit cast(0.9999*(select count(end_to_end_latency_in_ms) from stdin)as int)) group by operation_type,request_status" > tmp9999 ;

	sudo csvsql tmp99 tmp999 tmp9999 summary --query "select query,tmp99.operation_type,tmp99.request_status,count,size,E2E_avg,E2E99th,E2E999th,E2E999th,E2E_min,E2E_max,E2E_server_avg,E2E_server_min,E2E_server_max from tmp99,tmp999,tmp9999,summary where tmp99.operation_type=tmp999.operation_type and tmp999.operation_type=tmp9999.operation_type and summary.operation_type=tmp99.operation_type and tmp99.request_status=tmp999.request_status and tmp999.request_status=tmp9999.request_status and tmp99.request_status=summary.request_status" | sed 1d >> latency_report.csv ;

done 3< <(sudo csvcut -c STARTTIME $1) 4< <(sudo csvcut -c STOPTIME $1) 5< <(sudo csvcut -c QUERY $1)

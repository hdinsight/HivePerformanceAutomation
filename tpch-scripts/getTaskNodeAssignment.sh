echo "query,node,count" > node_assignment_report.csv ;

while IFS= read -r -d $'\0' file; do     
  t=$(echo $file | cut -d "/" -f2);
  zipgrep -h "nodeHttpAddress[^,]*" $file | sed 's/part.*: //g' | sed 's/nodeHttpAddress": //g'   | sed 's/"//g' | sed 's/,//g' | sort |  uniq -c | awk '{print $2 "," $1 }' | sed  "s/^/${t},/g" >> node_assignment_report.csv ;
done < <(find . -name *.zip -type f -print0)

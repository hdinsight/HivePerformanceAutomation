echo "query,node,count" > $2 ;

while IFS= read -r -d $'\0' file; do     
  t=$(echo $file | grep -oP "query[0-9]{2}");
  zipgrep -h "nodeHttpAddress[^,]*" $file | sed 's/part.*: //g' | sed 's/nodeHttpAddress": //g' | sed 's/["|,]//g' | sort |  uniq -c | awk '{print $2 "," $1 }' | sed  "s/^/${t},/g" | sed 's/:30060//g' >> $2 ;
done < <(find $1 -name "*.zip" -type f -print0)

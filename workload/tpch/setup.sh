#!/bin/bash

set -x

. ./config.sh
#check java
for f in gcc javac; do
	which $f > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Required program $f is missing. Please install or fix your path and try again."
		exit 1
	fi
done

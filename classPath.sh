#!/bin/bash

CLASSPATH=$(find ~/Alpha/sourceCode/java/ -not -path '**/.*' -type d \
	-print0 | sed "s/\/home/:\/home/g" | tr -d "\0")
export CLASSPATH=/usr/lib/jvm/java-17-openjdk-amd64/bin/$CLASSPATH

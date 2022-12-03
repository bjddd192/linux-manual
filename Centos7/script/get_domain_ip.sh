#!/bin/bash
domain=`cat domain.txt`
for i in $domain
do
IP=`ping $i -c 1 |awk 'NR==2 {print $5}' |awk -F ':' '{print $1}' |sed -nr "s#\(##gp"|sed -nr "s#\)##gp"`
    echo $i'|'$IP >> domain_ip.txt
done
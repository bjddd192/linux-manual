#!/bin/bash

proName(){
    productName=`dmidecode | grep Product|sed 's/^[ \t]*//g'`
    echo -e "\033[32;49;1m [服务器型号] \033[39;49;0m"
    echo -e "$productName"
}

sysVersion(){
    sysVersion=`cat /etc/issue|sed -n "1p"`
    echo -e "\033[32;49;1m [系统版本] \033[39;49;0m"
    echo -e "$sysVersion"
    
}

coreVersion(){
    coreVersion=`uname -r`
    echo -e "\033[32;49;1m [内核版本] \033[39;49;0m"
    echo -e "$coreVersion"
}
cpuInfo(){
    logicalNum=`cat /proc/cpuinfo |grep "processor"|wc -l`
    pysicalNum=`cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l`
    pysicalCoreNum=`cat /proc/cpuinfo| grep "cpu cores"| uniq |awk '{print $4}'`
    otherInfo=`cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c |awk '{print $2,$3,$7}'`
    firstCache=`cat /sys/devices/system/cpu/cpu0/cache/index0/size`
    let coreTotal=pysicalNum*pysicalCoreNum
    echo -e "\033[32;49;1m [cpu信息] \033[39;49;0m"
    echo -e "`getconf LONG_BIT`位，物理$coreTotal核($pysicalNum X $pysicalCoreNum)，逻辑$logicalNum核，$otherInfo，一级缓存$firstCache"
}

memInfo(){
    memSize=`free -m | grep Mem | awk '{print $2}'`
    swapSize=`free -m | grep Swap | awk '{print $2}'`
    echo -e "\033[32;49;1m [内存信息] \033[39;49;0m"
    echo -e "内存：$memSize Mb，交换分区：$swapSize Mb"
}

diskInfo(){
    diskInfo=`fdisk -l|grep "Disk /dev/sd"|tr "," ":" |awk -F ":" '{print $1,$2}'`
    echo -e "\033[32;49;1m [硬盘信息] \033[39;49;0m"
    echo -e "$diskInfo"
}

netInfo(){
    echo -e "\033[32;49;1m [网卡信息] \033[39;49;0m"
    for i in `ifconfig|egrep -E "em|eth"|grep -v Interrupt| awk '{print $1}'`
    do
    echo -e "\033[33;49;1m$i  \033[39;49;0m`ethtool $i | egrep -E "Speed|Duplex" | sed "s/^[ \t]//g"|sed -re '1,${N;s/\n/ /}' `"
    done
}

proName
sysVersion
coreVersion
cpuInfo
memInfo
diskInfo
netInfo

#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if [ $(cat /etc/issue |grep -v Kernel |awk '{print $1}') != "CentOS" ]; then
    apt-get install smartmontools -y
fi

echo ""
echo "---------------------服务器信息------------------------"
echo "服务器品牌："`dmidecode|grep "System Information" -A9 | grep Manufacturer |awk '{print $2}'`
echo "服务器型号："`dmidecode|grep "System Information" -A9 | grep Product |awk '{print $3}'`
echo "序列号："`dmidecode|grep "System Information" -A9 | grep Serial |awk '{print $3}'`
echo ""
echo ""
echo "---------------------主板信息--------------------------"
b=`dmidecode|grep "System Information" -A9|egrep Manufacturer: |awk '{print $2}'`
echo "主板品牌：" $b
c=`dmidecode |grep "System Information" -A9 |grep "Product Name:" |awk '{print $3}'`
echo "主板型号：" $c
echo ""
echo ""
echo "--------------------操作系统信息------------------------"
echo "系统：" `cat /etc/issue |grep -v Kernel`
echo "主机名：" `uname -n`
echo "内核版本：" `uname -r`
echo "" 
echo "----------------------CPU信息--------------------------"
echo "CPU个数：" `cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l`
echo "CPU型号：" `cat /proc/cpuinfo | grep 'model name' |uniq |awk -F : '{print $2}'`
echo "每个CPU核数：" `cat /proc/cpuinfo| grep "cpu cores"| uniq |awk '{print $4}'`
echo "CPU总个数：" `cat /proc/cpuinfo | grep "physical id" | uniq | wc -l`
echo "逻辑CPU个数（总核数）：" `cat /proc/cpuinfo| grep "processor"| wc -l`
echo ""
echo ""
echo "---------------------内存信息--------------------------"
echo "内存插槽总数：" `dmidecode |grep -A16 "Memory Device$" |grep Manufacturer: | wc -l`
echo "未使用插槽数：" `dmidecode |grep -A16 "Memory Device$" |grep 'Manufacturer: NO DIMM' | wc -l`
echo "厂商如下："
    dmidecode -t memory |grep Manufacturer
echo "内存型号："
    dmidecode -t memory |grep 'Part Number'
echo "每条内存大小："
    dmidecode|grep -A5 "Memory Device"|grep Size|grep -v Range
echo "每条内存频率："
    dmidecode|grep -A16 "Memory Device"|grep Speed
echo "总内存（GB）：" `free -g |grep Mem |awk '{print $2}'`
echo ""
echo ""
echo "---------------------硬盘信息--------------------------"
echo "硬盘厂商、型号、序列号：" `smartctl -a /dev/sda |egrep "Device Model:|Serial Number:"`
echo "硬盘数量、容量：" `fdisk -l |grep "Disk /dev/sd"`
echo ""
echo ""
echo "---------------------网卡信息--------------------------"
echo "网卡设备："
lspci | grep Ethernet
echo ""
echo ""

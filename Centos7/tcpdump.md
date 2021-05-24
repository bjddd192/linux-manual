```sh
# 查看tcpdump是否安装
rpm -ql tcpdump
# yum安装
yum -y install tcpdump

# 根据来源和目标地址抓包， -c指定抓包数量  -t不显示时间戳  -w指定存放路径　
tcpdump -i eth0 src host 10.0.43.30 -c 300 -t -vvv -w /tmp/tcpdump.pcap
tcpdump -i eth0 tcp port 8443 -c 300 -t -vvv -w /tmp/tcpdump.pcap
tcpdump -s 0 -A 'tcp dst port 8443 and (tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x504f5354)' -c 300 -vvv -w /tmp/tcpdump.pcap
# 查看抓包文件
tcpdump -r /tmp/tcpdump.pcap 

# 根据目标地址抓包
tcpdump -i any -nn dst host 211.156.219.132 -c 300 -t -vvv -w /tmp/tcpdump.pcap

```

#### 参考资料

[Centos抓包方法](https://www.cnblogs.com/sonnyBag/p/11548136.html)

[tcpdump使用示例](https://www.cnblogs.com/dspace/p/9750354.html)


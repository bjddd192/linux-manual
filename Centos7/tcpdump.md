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

# 顺丰请求故障排查
tcpdump -i any -nn host 210.21.231.12 -c 5000 -t -vvv -w /tmp/tcpdump.pcap

# 查看哪个容器应用连了数据库
tcpdump -i any port 3306 and host polardb-test.lesoon.lan

# 循环抓包
tcpdump -i eth1 'net 10.250.108.0/24' -v -w /tmp/tmp.pcap -s 0 -C 50 -W 50
# -C 50: 当捕获文件的大小达到 50 MB 时，自动滚动（即关闭当前文件，并开启一个新的捕获文件）。这有助于管理大型捕获文件，防止单个文件变得过大。
# -W 20: 与 -C 选项结合使用，指定最多保留 20 个滚动文件。当达到这个数量时，最老的文件将被自动删除，以确保不会占用过多的磁盘空间
find . -name "*.pcap*" -newermt "2025-07-08 16:49:59" ! -newermt "2025-07-08 16:52:01" -exec tar -rvf pcap.tar {} \; && gzip pcap.tar
# 压缩匹配的文件
```

#### 参考资料

[Centos抓包方法](https://www.cnblogs.com/sonnyBag/p/11548136.html)

[tcpdump使用示例](https://www.cnblogs.com/dspace/p/9750354.html)


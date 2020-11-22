```sh
# netstat命令找出连接本机最多前5个IP地址
netstat -ntu | grep -v 127.0.0.1 | tail -n +3 | awk '{ print $5}' | cut -d : -f 1 | sort | uniq -c| sort -n -r | head -n 5

# 查看服务IP连接数
netstat -anto | grep 6379 | awk '{print $5}' | awk -F':' '{print $1}' | sort | uniq -c | sort -rn

# 查看端口连接情况
netstat -alntp | grep 21051
netstat -alntp | grep 6379 | awk '{print $5}' | awk -F':' '{print $1}' | sort | uniq -c | sort -rn
```



### 参考资料

[net-tools工具netstat 命令](https://www.cnblogs.com/pipci/p/12531510.html)


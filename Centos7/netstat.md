```sh
# netstat命令找出连接本机最多前5个IP地址
netstat -ntu | grep -v 127.0.0.1 | tail -n +3 | awk '{ print $5}' | cut -d : -f 1 | sort | uniq -c| sort -n -r | head -n 5
```


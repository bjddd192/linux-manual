# curl 常用操作

### 查看请求耗时

```sh
curl -L --output /dev/null --silent --show-error --write-out '\n\nnamelookup:    %{time_namelookup}\nconnect:       %{time_connect}\nsslhandshake:  %{time_appconnect}\npretransfer:   %{time_pretransfer}\nredirect:      %{time_redirect}\nfirstbyte:     %{time_starttransfer}\ntotal:         %{time_total}\n\n\n' "https://xx.cn/gateway"  \
--resolve "xx.cn:xx.xx.xx.x"
```

### 查看网站连接耗时

```sh
curl -w "TCP handshake: %{time_connect}, SSL handshake: %{time_appconnect}\n" -so /dev/null https://56.belle.net.cn

curl -w "总时间: %{time_total}s\n名称解析时间: %{time_namelookup}s\n连接时间: %{time_connect}s\nTLS握手时间: %{time_appconnect}s\n等待时间: %{time_starttransfer}s\n数据传输时间: %{time_total}s\nHTTP状态码: %{http_code}\n"  http://183.134.0.198:18086 -v

curl -w "总时间: %{time_total}s\n名称解析时间: %{time_namelookup}s\n连接时间: %{time_connect}s\nTLS握手时间: %{time_appconnect}s\n等待时间: %{time_starttransfer}s\n数据传输时间: %{time_total}s\nHTTP状态码: %{http_code}\n"  http://172.25.60.13:8085 -v
```

### 查看网站证书

```sh
curl -k -v https://www.baidu.com
```


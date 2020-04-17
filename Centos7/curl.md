# curl 常用操作

### 查看请求耗时

```sh
curl -L --output /dev/null --silent --show-error --write-out '\n\nnamelookup:    %{time_namelookup}\nconnect:       %{time_connect}\nsslhandshake:  %{time_appconnect}\npretransfer:   %{time_pretransfer}\nredirect:      %{time_redirect}\nfirstbyte:     %{time_starttransfer}\ntotal:         %{time_total}\n\n\n' "https://xx.cn/gateway"  \
--resolve "xx.cn:xx.xx.xx.x"
```


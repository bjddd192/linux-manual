# 简介

```sh
# 查看文件修改时间(精确到秒)
ls --full-time
# 要显示更多信息，用 stat 命令
stat test.txt

# 查看 java 堆内存、堆栈
jmap -histo 19 | more
jmap -dump:format=b,file=/tmp/abc.txt 19
jmap -dump:format=b,file=19.bin 19
# 导出线程栈
jstack -l 19 > 19.txt

# java 垃圾回收
jcmd <pid> GC.run

# centos7 安装 ftp 客户端
rpm -ivh http://mirror.centos.org/centos/7/os/x86_64/Packages/ftp-0.17-67.el7.x86_64.rpm

# ansible 执行脚本特殊符号加转义
ansible 192.190.0.91 -m shell -a "docker rmi -f \$( docker images | grep '<none>' | tr -s ' ' | cut -d ' ' -f 3)"
```


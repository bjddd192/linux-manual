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

[linux命令-寻找超过100M的文件，并将其删除](https://www.cnblogs.com/f-zhao/p/6400089.html)

```sh
find / -type f -size +100M | xargs rm -rf

其中第一个/表示路径，此时表示的是根目录，也就是搜索全部的文件

-type表示类型

f表示是文件

-size 表示大小

+100M：表示大于100M

后面就是执行的命令。

当然也可以寻找特定后缀的文件，比如：find / -name "*.mp3" |xargs rm -rf，就是寻找以mp3结尾的文件并删除。一般我们在删除之前需要确认删除的文件是否正确，所以我们一般是去掉后面的执行命令，先找出文件列表，再执行。

事例：
find /data/docker_volumn/jenkins/maven-repository/com/belle -type f -size +50M | xargs rm -rf

# 查询服务器有被哪些机器连接
netstat -ntu | grep 10.0.43.251:8443 | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n
```

centos安装ab工具给网站进行压力测试

```sh
yum install httpd-tools -y
ab -c 3000 -n 2000000 -k http://10.234.6.89/helloworld.html 
wrk -t48 -c1000 -d5m -T30s http://10.234.6.89/helloworld.html
```

firewall 防火墙操作

```sh
# 查看放行端口
firewall-cmd --zone=public --list-ports
# 放行端口
firewall-cmd --permanent --zone=public --add-port=80/tcp
# 生效配置
firewall-cmd --reload
```

查看mtu值

```sh
cat /sys/class/net/eth0/mtu
```

查看是不是虚拟机

```sh
dmidecode -s system-product-name
dmesg | grep -i virtual
```

实用小脚本

```sh
# 查看本机IP
ip route get 1 | awk '{print $NF;exit}'

# 正则表达式提取内网域名
cat oms-e-api-prod.yml | egrep -i '[a-zA-Z0-9]*[a-zA-Z0-9|.|-]*.bjm6v.belle.lan' | sort
```

常用技巧

[Linux机器之间免密登录设置](https://blog.csdn.net/u013415591/article/details/81943189)

[解决 ssh_exchange_identification: read: Connection reset by peer问题](https://blog.csdn.net/lilygg/article/details/86187028)

[使用SSH登录Linux系统的ECS实例时提示“requirement "uid >= 1000" not met by user "root"”错误](https://help.aliyun.com/knowledge_detail/41491.html)

ssh 10.250.15.40 -l k8sloger
k8sloger@10.250.15.40's password: 
# 查看异常日志
docker logs -f --tail 20 webssh2
# 解锁用户
pam_tally2 --user=k8sloger --reset

# 清理日志
journalctl --vacuum-time=1days
rm -rf /var/log/messages-*


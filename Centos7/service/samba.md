# samba

## 安装服务

```sh
rpm -qa | grep samba
yum -y install samba
```

## 配置服务

配置文件地址：`/etc/samba/smb.conf`

内容：

```config

```

## 启动服务

```sh
systemctl restart smb
systemctl enable smb
systemctl status smb
netstat -nltp | grep smbd
```

## 使用共享服务

### linux

```sh
yum -y install cifs-utils

mkdir -p /mnt/samba/axure
cd /mnt/samba/axure

# 挂载
# 如调整了服务器的地址或者端口，在umount时会报错：target is busy 或者 Host is down
# 可使用mount进行覆盖就正常了
mount -t cifs -o username=root,password=,port=555 //172.20.32.36/axure /mnt/samba/axure 
ls /mnt/samba/axure 

# 取消挂载
umount -f /mnt/samba/axure
```

### windows

445端口变更未成功，遗憾。

```bash
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=445 connectaddress=172.20.32.36 connectport=1314

netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=445
```

#### 参考资料

[修改Windows SMB相关服务的默认端口](http://www.360doc.com/content/19/0109/17/61724986_807731212.shtml)

[后WannaCrypt蠕虫勒索病毒445端口被封的网上邻居共享方法](https://dog.xmu.edu.cn/2017/05/19/windows-network-neighborhood.html)

[netsh interface portproxy的一个简单例子](https://www.cnblogs.com/hnsongbiao/p/9125067.html)


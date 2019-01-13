# samba

samba 网络共享服务虽然速度不理想，但它是跨各种操作系统最稳定的网络共享存储方案，且部署简单，字符集也不会有任何问题。当然由于勒索病毒的出现，引发了共享安全问题，导致很多网络环境禁止使用 samba 服务，真是很遗憾，希望未来可以有更好的共享方案来作为替代。但 samba 服务本身还是非常有价值的，依然可以作为个人使用，快速实现跨系统的文件共享。

## 安装服务

```sh
rpm -qa | grep samba

yum -y install samba
```

## 配置服务

配置文件地址：`/etc/samba/smb.conf`

内容：

```ini
[global]
        # 自定义smb端口，并保留445端口，默认值为 445 139
        smb ports = 445 555
        workgroup = SAMBA
        server string = Samba Server
        netbios name = Samba Server
        display charset = UTF-8
        unix charset = UTF-8
        dos charset = GB2312
        max log size = 50
        security = user
        map to guest = Bad User

[html]
        comment = static web
        path = /home/docker/nginx/html
        public = yes
        writable = yes
        browsable = yes
        guest ok = yes
        create mode = 0777
        directory mode = 0777

[axure]
        comment = axure
        path = /home/docker/manual_online/html/axure
        public = yes
        writable = yes
        browsable = yes
        guest ok = yes
        create mode = 0777
        directory mode = 0777

[sfds]
        comment = sfds
        path = /usr/local/sfds
        public = yes
        writable = no
        browsable = yes
        guest ok = yes
        create mode = 0744
        directory mode = 0744

[RFAPK]
        comment = axure
        path = /usr/local/RFAPK
        public = yes
        writable = yes
        browsable = yes
        guest ok = yes
        create mode = 0777
        directory mode = 0777
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

### mac

访达 --> 连接服务器，添加服务器，如：

```sh
smb://172.20.32.36
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


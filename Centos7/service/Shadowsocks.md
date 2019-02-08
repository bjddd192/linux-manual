# Shadowsocks

科学上网神器。

## 服务端

已购买国外服务器搭建完成，这里暂不做记录。

## 客户端

安装 shadowsocks：

```sh
yum -y install epel-release
yum -y install python-pip
pip install shadowsocks
# 查看已安装软件列表
pip freeze
mkdir -p /etc/shadowsocks
```

配置 shadowsocks：

```sh
tee /etc/shadowsocks/shadowsocks.json <<-'EOF'
{
	"server": "x.x.x.x",
	"server_port": 8087,
	"password": "dockerMan",
	"method": "aes-256-cfb",
	"local_address": "127.0.0.1",
	"local_port": 1080,
	"timeout": 300,
	"fast_open": false,
	"workers": 1
}
EOF
```

配置自启动 shadowsocks：

```sh
tee /etc/systemd/system/shadowsocks.service <<-'EOF'
[Unit]
Description=Shadowsocks
[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/sslocal -c /etc/shadowsocks/shadowsocks.json
[Install]
WantedBy=multi-user.target
EOF
```

启动 shadowsocks 服务：

```sh
systemctl enable shadowsocks.service
systemctl restart shadowsocks.service
systemctl status shadowsocks.service
```

验证客户端：

```sh
curl --socks5 127.0.0.1:1080 http://httpbin.org/ip
curl http://httpbin.org/ip
```

验证代理：

```sh
export all_proxy=http://127.0.0.1:1080
export ftp_proxy=http://127.0.0.1:1080
export http_proxy=http://127.0.0.1:1080
export https_proxy=http://127.0.0.1:1080
export no_proxy=localhost,172.17.0.0/16,192.168.0.0/16.,127.0.0.1,10.10.0.0/16
curl -I www.google.com
```

发现此时 http 请求并不能代理成功，因为 shadowsocks 是 socks5 代理，需要再安装一个代理服务 privoxy。

[Privoxy 官网](http://www.privoxy.org/)

先取消使用代理：

```sh
while read var; do unset $var; done < <(env | grep -i proxy | awk -F= '{print $1}')
```

安装 privoxy：

```
export http_proxy=""
export https_proxy=""
yum -y install privoxy
systemctl enable privoxy
systemctl restart privoxy
systemctl status privoxy
```

配置 privoxy：

```sh
tee /etc/privoxy/config <<-'EOF'
listen-address 127.0.0.1:8118  # 8118 是默认端口，不用改
forward-socks5t / 127.0.0.1:1080 .  # 转发到本地端口，注意最后有个点
EOF
```

再来验证代理：

```sh
export all_proxy=http://127.0.0.1:8118
export ftp_proxy=http://127.0.0.1:8118
export http_proxy=http://127.0.0.1:8118
export https_proxy=http://127.0.0.1:8118
export no_proxy=localhost,172.17.0.0/16,192.168.0.0/16.,127.0.0.1,10.10.0.0/16
curl -I www.google.com
```

发现可以正常连接了，哦耶。

## 参考资料

[CentOS 7 安装使用Shadowsocks客户端](https://www.jianshu.com/p/824912d9afda)

# Nginx

### 基本概念

- connection

- request

- keepalive


### 重点内容

**为什么nginx可以采用异步非阻塞的方式来处理呢，或者异步非阻塞到底是怎么回事呢？**

异步非阻塞的事件处理机制，具体到系统调用就是像select/poll/epoll/kqueue这样的系统调用。它们提供了一种机制，让你可以同时监控多个事件，调用他们是阻塞的，但可以设置超时时间，在超时时间之内，如果有事件准备好了，就返回。这种机制正好解决了我们上面的两个问题，拿epoll为例(在后面的例子中，我们多以epoll为例子，以代表这一类函数)，当事件没准备好时，放到epoll里面，事件准备好了，我们就去读写，当读写返回EAGAIN时，我们将它再次加入到epoll里面。这样，只要有事件准备好了，我们就去处理它，只有当所有事件都没准备好时，才在epoll里面等着。这样，我们就可以并发处理大量的并发了，当然，这里的并发请求，是指未处理完的请求，线程只有一个，所以同时能处理的请求当然只有一个了，只是在请求间进行不断地切换而已，切换也是因为异步事件未准备好，而主动让出的。这里的切换是没有任何代价，你可以理解为循环处理多个准备好的事件，事实上就是这样的。与多线程相比，这种事件处理方式是有很大的优势的，不需要创建线程，每个请求占用的内存也很少，没有上下文切换，事件处理非常的轻量级。并发数再多也不会导致无谓的资源浪费（上下文切换）。更多的并发数，只是会占用更多的内存而已。 我之前有对连接数进行过测试，在24G内存的机器上，处理的并发请求数达到过200万。现在的网络服务器基本都采用这种方式，这也是nginx性能高效的主要原因。

推荐设置worker的个数为cpu的核数，在这里就很容易理解了，更多的worker数，只会导致进程来竞争cpu资源了，从而带来不必要的上下文切换。而且，nginx为了更好的利用多核特性，提供了cpu亲缘性的绑定选项，我们可以将某一个进程绑定在某一个核上，这样就不会因为进程的切换带来cache的失效。像这种小的优化在nginx中非常常见，同时也说明了nginx作者的苦心孤诣。比如，nginx在做4个字节的字符串比较时，会将4个字符转换成一个int型，再作比较，以减少cpu的指令数等等。

在nginx中，每个进程会有一个连接数的最大上限，这个上限与系统对fd的限制不一样。在操作系统中，通过ulimit -n，我们可以得到一个进程所能够打开的fd的最大数，即nofile，因为每个socket连接会占用掉一个fd，所以这也会限制我们进程的最大连接数，当然也会直接影响到我们程序所能支持的最大并发数，当fd用完后，再创建socket时，就会失败。nginx通过设置worker_connectons来设置每个进程支持的最大连接数。如果该值大于nofile，那么实际的最大连接数是nofile，nginx会有警告。nginx在实现时，是通过一个连接池来管理的，每个worker进程都有一个独立的连接池，连接池的大小是worker_connections。这里的连接池里面保存的其实不是真实的连接，它只是一个worker_connections大小的一个ngx_connection_t结构的数组。并且，nginx会通过一个链表free_connections来保存所有的空闲ngx_connection_t，每次获取一个连接时，就从空闲连接链表中获取一个，用完后，再放回空闲连接链表里面。

在这里，很多人会误解worker_connections这个参数的意思，认为这个值就是nginx所能建立连接的最大值。其实不然，这个值是表示每个worker进程所能建立连接的最大值，所以，一个nginx能建立的最大连接数，应该是worker_connections * worker_processes。当然，这里说的是最大连接数，对于HTTP请求本地资源来说，能够支持的最大并发数量是worker_connections * worker_processes，而如果是HTTP作为反向代理来说，最大并发数量应该是worker_connections * worker_processes/2。因为作为反向代理服务器，每个并发会建立与客户端的连接和与后端服务的连接，会占用两个连接。

### 版本

#### 开源版本

[nginx.org](http://nginx.org/)

[OpenResty.org](http://OpenResty.org)

[tengine](http://tengine.taobao.org/)

#### 商业版本

[nginx.com](https://www.nginx.com/)

[OpenResty.com](http://OpenResty.com)

#### 开源版本下载

[nginx download](http://nginx.org/download/)

### 实验环境

#### 编译安装 nginx

``` sh
yum -y install openssl openssl-devel pcre-devel gd-devel lua-devel
cd /usr/local/games
# 设置 nginx 版本
export v_nginx_version=nginx-1.10.1
# 下载安装包
wget http://10.0.43.24:8066/nginx/stable/$v_nginx_version.tar.gz
# 解压安装包
tar -xzf $v_nginx_version.tar.gz 
# 进入源码目录
cd $v_nginx_version
# 设置 nginx 配置文件语法高亮显示
mkdir -p ~/.vim
cp -r contrib/vim/* ~/.vim/
# 查看 nginx 帮助文件
man man/nginx.8 
# 查看编译参数
./configure --help
# 使用默认编译(指定安装目录)
./configure --prefix=/usr/local/$v_nginx_version --with-http_ssl_module
# 查看有哪些模块会被编译进 nginx
cat objs/ngx_modules.c 
# 执行编译
make
# 查看编译成果物
ls objs/
# 执行安装(第一次安装使用)
make install

# mac下编译安装如报错：
# ./configure: error: the HTTP rewrite module requires the PCRE library.
# 需要先安装 pcre
brew install pcre
# ./configure: error: the HTTP image filter module requires the GD library.
brew install gd

./configure --prefix=/Users/yanglei/09_nginx/nginx-1.16.1 --with-openssl=../openssl-1.1.1d --with-http_ssl_module --with-http_image_filter_module=dynamic --with-http_realip_module
make
make install
```

##### 参考资料

[mac os x 10.13 编译安装 nginx](https://segmentfault.com/a/1190000012399626)

[Nginx替换OpenSSL为LibreSSL](https://www.ctolib.com/amp/topics-85593.html)

[Install gd on Mac OSX](http://macappstore.org/gd/)

#### 编译安装 openresty

```sh
cd /usr/local/games
# 设置 nginx 版本
export v_openresty_version=openresty-1.15.8.2
# 下载安装包
wget http://10.0.43.24:8066/nginx/stable/$v_openresty_version.tar.gz
# 解压安装包
tar -xzf $v_openresty_version.tar.gz 
# 进入源码目录
cd $v_openresty_version
# 安装 SSL 必须组件
yum install -y openssl-devel
# 使用默认编译(指定安装目录)
./configure --prefix=/usr/local/$v_openresty_version --with-http_ssl_module
# 查看有哪些模块会被编译进 nginx
cat build/nginx-1.15.8/objs/ngx_modules.c 
# 执行编译
make
# 查看编译成果物
ls build/nginx-1.15.8/objs/
# 执行安装(第一次安装使用)
make install
```

#### 安装 GoAccess

GoAccess 被设计成快速的并基于终端的日志分析工具。其核心理念是不需要通过 Web 浏览器就能快速分析并实时查看 Web 服务器的统计数据(这对于需要使用 SSH 来对访问日志进行快速分析或者就是喜欢在终端环境下工作的人来说是超赞的)。

[GoAccess 官网](https://goaccess.io/)

[GoAccess 中文官网](https://www.goaccess.cc/)

```sh
# 安装 goaccess
yum install goaccess

# 使用 goaccess
cd /usr/local/openresty-1.15.8.2/logs
goaccess geek.zorin.pub.access.log -o ../html/report.html --real-time-html --time-format='%H:%M:%S' --date-format='%d/%b/%Y' --log-format=COMBINED

# 测试地址：
# http://geek.zorin.pub/report.html

# mac下安装
brew install goaccess
cd /Users/yanglei/09_nginx/nginx-1.16.1/logs
# mac下 goaccess:1.3 对中文支持不好，暂用英文
LANG="en_US.UTF-8" bash -c "goaccess www.zorin.xin.access.log -o ../html/report.html --real-time-html --time-format='%H:%M:%S' --date-format='%d/%b/%Y' --log-format=COMBINED"

# GoAccess v1.3 支持中文与 docker 部署，后面可以再深入研究一下 
```

##### 参考资料

[使用GoAccess构建实时日志分析系统](https://www.cnblogs.com/longren/p/10945623.html)

[GoAccess中文界面显示配置](https://blog.51cto.com/linuxg/2335007)

#### 生成免费 SSL 证书

```sh
# centos7
yum install -y certbot python2-certbot-nginx
# certbot 生成证书时，需要读取默认nginx，需要将 sbin/nginx 加入到 PATH 里 
# or ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/sbin/nginx
ln -s /usr/local/openresty-1.15.8.2/nginx/sbin/nginx /usr/local/sbin/nginx
# 生成免费https证书(三个月有效期)
# 需要真实存在的外网域名解析，并在对应的 nginx 云服务器上执行。
certbot --nginx --nginx-server-root=/usr/local/openresty-1.15.8.2/nginx/conf -d sfds.zorin.xin
```

##### 参考资料

[Nginx 通过 certbot 为网站自动配置 SSL 证书并续期](https://www.cnblogs.com/Crazy-Liu/p/11039859.html)

[使用Certbot获取免费泛域名(通配符)证书](https://www.jianshu.com/p/1eb7060c5ede)

#### 常用命令

```sh
# 设置 nginx 版本
export v_nginx_version=nginx-1.10.1
# 进入源码目录
cd /usr/local/$v_nginx_version
# 查看 nginx 版本
sbin/nginx -v
# 查看 nginx 编译信息
sbin/nginx -V
# 启动 nginx
sbin/nginx
# 查看 nginx 进程
ps -ef | grep nginx
# 重载 nginx
sbin/nginx -s reload

# 日志切割
mv logs/access.log logs/bak.log
# 重新开始记录日志文件
sbin/nginx -s reopen

# 优雅升级 nginx
# 查看 nginx 进程
ps -ef | grep nginx
# 备份老的 nginx
cp sbin/nginx sbin/nginx.old
# 拷贝新版本的 nginx
cp /usr/local/nginx-1.16.1/sbin/nginx /sbin/
# 发送信号启动新的 nginx（新老进程共存，但连接已切换到新的版本）
kill -USR2 29537
# 优雅关闭老的 work 进程(老 master 进程还保留，可用于回滚版本)
kill -WINCH 29537
/sbin/nginx -v
```

#### 正则表达式

```sh
# prcetest
pcretest
PCRE version 8.43 2019-02-23

  re> /^\/admin\/website\/article\/(\d+)\/change\/uploads\/(\w+)\/(\w+)\.(png|jpg|gif|jpeg|b mp)$/
data> /admin/website/article/35/change/uploads/party/5.jpg
 0: /admin/website/article/35/change/uploads/party/5.jpg
 1: 35
 2: party
 3: 5
 4: jpg
```

### 优化命令

```sh
# cpu 优化
# 查看 cpu 负载
top
uptime
# 查看上下文切换次数
vmstat 1
# yum install -y dstat
dstat
# 查看时间、CPU、磁盘读写、IO、负载、内存、网络、最高的CPU占用和最高的内存占用
dstat -tcdrlmn --top-cpu --top-mem
# 查看8颗核心，每颗核心的使用情况和CPU使用情况
dstat -cl -C 0,1,2,3,4,5,6,7 --top-cpu
# 针对进程查看 cpu 上下文切换状态
pidstat -w -p 13789 1
# 查看cpu缓存
cat /sys/devices/system/cpu/cpu1/cache/index0/size 
cat /sys/devices/system/cpu/cpu1/cache/index1/size
cat /sys/devices/system/cpu/cpu1/cache/index2/size  
cat /sys/devices/system/cpu/cpu1/cache/index3/size 
cat /sys/devices/system/cpu/cpu1/cache/index3/shared_cpu_list
# numa架构
# yum -y install numactl
numactl --hardware
numastat

# 内存优化

# 磁盘 io 优化
# bps 压测工具：FIO


# 网络优化
# tcp连接三次握手
# 查看tcp进程状态
netstat -anp | grep tcp
# 查看内核参数
sysctl -a | grep net.ipv4
sysctl -a | grep net.ipv4.ip
sysctl -a | grep net.ipv4.tcp_max
sysctl -a | grep net.ipv4.tcp_syn
# net.ipv4.tcp_syn_retries 主动建立连接时，发SYN的重试次数
# net.ipv4.ip_local_port_range 建立连接时的本地端口可用范围
# net.ipv4.tcp_syn_retries 被动建立连接时，发SYN/ACK的重试次数
# net.ipv4.tcp_max_syn_backlog SYN_RCVD状态连接的最大个数

# 内核优化
limit -a
sysctl -a | grep file-max
sysctl -a | grep file-nr
# 开启TFO(0:关闭 1:作为客户端时可用试用 2:作为服务端时可用 3:总是使用)
sysctl -a | grep net.ipv4.tcp_fastopen

# 滑动窗口
# 丢包重传
# 达到上限后，更新路由配置
net.ipv4.tcp_retries1
# 达到上限后，关闭TCP连接
net.ipv4.tcp_retries2

# TCP缓冲区
sysctl -a | grep net.ipv4.tcp | grep mem

BDP=带宽(bps)*时延(s), 吞吐量=窗口/时延
```

### 应对攻击

#### 应对SYN攻击

```sh
# 接收自网卡、但未被内核协议栈处理的报文队列长度
net.core.netdev_max_backlog
# SYN_RCVD状态连接的最大个数
net.ipv4.tcp_max_syn_backlog
# 超出处理能力，对新来的SYN直接回包RST，丢弃连接
net.ipv4.tcp_abort_on_overflow
# 当SYN队列满后，新的SYN不进入队列，计算出cookie再以SYN+ACK中的序列号返回客户端
net.ipv4.tcp_syncookies
# 系统级最大backlog队列长度
net.core.somaxconn
```

### 网络抓包

#### 抓包工具

[Wireshark](https://www.wireshark.org/download.html)

```sh
# 捕获过滤器示例
host 127.0.0.1 and port 18080
```

##### 参考资料

[Wireshark使用入门](https://www.cnblogs.com/cocowool/p/wireshark_tcp_http.html)

### 学习资料

[Nginx开发从入门到精通](http://tengine.taobao.org/book/index.html)

### 参考资料

[C10K问题](https://www.jianshu.com/p/ba7fa25d3590)
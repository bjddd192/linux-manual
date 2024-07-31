#!/bin/bash
. /etc/profile
#Date: 2024.01.30
#Filename: luoge_linux_check.sh
#wukang
#Description: Security check
#version 1.0

############################################################
# 颜色输出功能
#
#ECHO_RED red
#ECHO_GREEN green
#ECHO_YELLOW yello
#ECHO_BLUE blue
#ECHO_WHITE white
#
#ECHO_INFO "#info~~~~~~#"
#ECHO_WARNING "warning~~~~~"
#ECHO_SUCCESS "sucess~~~~~"
#ECHO_ERROR "error!!!!!!"
############################################################
# 颜色输出日志文本
function ECHO_TEXT() {
    echo -e " \e[0;$2m$1\e[0m"
} 

# 红色文字输出
function ECHO_RED() {
    echo $(ECHO_TEXT "$1" "31") 
} 

# 绿色文字输出
function ECHO_GREEN() {
    echo $(ECHO_TEXT "$1" "32") 
} 

# 黄色文字输出
function ECHO_YELLOW() { 
    echo $(ECHO_TEXT "$1" "33") 
} 

# 蓝色文字输出
function ECHO_BLUE() { 
    echo $(ECHO_TEXT "$1" "34") 
}

# 白色文字输出
function ECHO_WHITE() { 
    echo $(ECHO_TEXT "$1" "27") 
}


############################################################
# 颜色日志输出功能
############################################################
# 红色日志输出
function ECHO_ERROR() {
    TimeNow=$(/usr/bin/date +"%Y-%m-%d %H:%M:%S")
    echo $(ECHO_TEXT "${TimeNow}\t[ERROR]\t$1" "31") 
} 

# 绿色日志输出
function ECHO_SUCCESS() {
    TimeNow=$(/usr/bin/date +"%Y-%m-%d %H:%M:%S")
    echo $(ECHO_TEXT "${TimeNow}\t[SUCCESS]\t$1" "32") 
} 

# 黄色日志输出
function ECHO_WARNING() { 
    TimeNow=$(/usr/bin/date +"%Y-%m-%d %H:%M:%S")
    echo $(ECHO_TEXT "${TimeNow}\t[WARNING]\t$1" "33") 
} 

# 白色日志输出
function ECHO_INFO() { 
    TimeNow=$(/usr/bin/date +"%Y-%m-%d %H:%M:%S")
    echo $(ECHO_TEXT "${TimeNow}\t[INFO]\t$1" "27") 
}

echo '
 _                  _____      
| |                / ____|     
| |    _   _  ___ | |  __  ___ 
| |   | | | |/ _ \| | |_ |/ _ \
| |___| |_| | (_) | |__| |  __/
|______\__,_|\___/ \_____|\___|       v1.0'

echo
echo "##########################################################################"
echo "#                                                                        #"
echo "#警告:本脚本只是一个检查的操作,未对服务器做任何修改,管理员可以根据此报告 #"
echo "#进行相应的安全整改                                                      #"
echo "##########################################################################"
echo

timer_start=`date "+%Y-%m-%d %H:%M:%S"`
sleep 3

ECHO_INFO "start..."

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>身份鉴别<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "a）应对登录的用户进行身份标识和鉴别，身份标识具有唯一性，身份鉴别信息具有复杂度要求并定期更换；"

echo "1、检查UID为0的用户"
awk -F: '($3==0)' /etc/passwd
echo

echo "2、检查系统可登录的用户"
login_user=`paste -d ":" /etc/passwd /etc/shadow |awk -v OFS=":" -F ':' '($7 !~ "(/sbin/nologin|/bin/sync|/sbin/halt|/sbin/shutdown)") {print $1}'| awk '{printf "%s,", $0}'`
echo $login_user
echo


echo "3、检查系统可登录的,且密码字段为空的用户"
no_pass_user=`paste -d ":" /etc/passwd /etc/shadow |awk -v OFS=":" -F ':' '($7 !~ "(/sbin/nologin|/bin/sync|/sbin/halt|/sbin/shutdown)")  {print $0}'|awk -F: -v OFS=":" '$9==""{print $1}'| awk '{printf "%s,", $0}'`
echo $no_pass_user
echo


echo "4、检查密码有效期"
cat /etc/login.defs | grep -E "^PASS"
if [[ `cat /etc/login.defs |grep "^PASS_MAX_DAYS"|awk '{print $2}'` -eq 99999 ]];then
  ECHO_YELLOW "密码有效期:未设置"
elif [[ `cat /etc/login.defs |grep "^PASS_MAX_DAYS"|awk '{print $2}'` -ge 90 ]];then
  ECHO_YELLOW "PASS_MAX_DAYS密码有效过长,建议设置90天"
else
  ECHO_GREEN "密码有效期已设置。"
fi
echo

echo "5、检查密码复杂度"
grep "pam_cracklib.so" /etc/pam.d/system-auth
if [ $? == 0 ];then
  ECHO_GREEN "密码复杂度:已设置"
else
  ECHO_YELLOW "密码复杂度:未设置"
fi
echo

echo "b）应具有登录失败处理功能，应配置并启用结束会话、限制非法登录次数和当登录连接超时自动退出等相关措施；"
echo "1、检查登录失败处理策略"
egrep "pam_tally2.so|pam_faillock.so" /etc/pam.d/system-auth
if [ $? == 0 ];then
  ECHO_GREEN "登录失败处理策略:已设置"
else
  ECHO_YELLOW "登录失败处理策略:未设置"
fi
echo

echo "2、检查登录连接超时"
grep "TMOUT" /etc/profile
if [ $? == 0 ];then
  ECHO_GREEN "登录连接超时:已设置"
else
  ECHO_YELLOW "登录连接超时:未设置"
fi
echo

sleep 2
echo "c）当进行远程管理时，应采取必要措施防止鉴别信息在网络传输过程中被窃听；"
echo "1、检查是否开启了telnt、ftp"
ss -tunlp|egrep "ftp|telnet"|wc -l  >/dev/null 2>&1
if [ $? == 0 ];then
  ECHO_GREEN "未开启telnet、ftp"
else
  ECHO_YELLOW "已开启telnet或ftp"
fi
netstat -tnlp
echo


echo "d）应采用口令、密码技术、生物技术等两种或两种以上组合的鉴别技术对用户进行身份鉴别，且其中一种鉴别技术至少应使用密码技术来实现。"
echo "1、检查是否开启了key登录，确认公钥里面是否有内容"
keys_file=`cat /etc/ssh/sshd_config |grep AuthorizedKeysFile|awk '{print "/root/"$2}'`
if [[ -f $keys_file ]];then
  if [[ `cat $keys_file|wc -l` -gt 0 ]];then
    ECHO_GREEN "存在公钥文件${keys_file},且有内容。"
  else
    ECHO_YELLOW "在公钥文件${keys_file},无内容。"
  fi
  else
    ECHO_YELLOW "未配置秘钥登录。"
fi
echo

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>访问控制<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "a）应对登录的用户分配账户和权限；"
echo "1、检查关键文件权限分配"
ls -l /etc/passwd /etc/shadow

filelist="/etc/passwd /etc/shadow"

for file in ${filelist}
do
  if [[ `stat -c "%a" ${file}` -le 644 ]];then
    ECHO_GREEN "$file权限值设置小于644"
    else
    ECHO_RED "$file权限值设置大于644"
  fi
done
echo

echo "b) 应重命名或删除默认账户，修改默认账户的默认口令；"
echo "1、检查是否禁用root用户"
if [[ `cat /etc/ssh/sshd_config |grep ^PermitRootLogin|wc -l` -eq 0 ]];then
  ECHO_YELLOW "/etc/ssh/sshd_config文件未配置禁用root"
else
  if [[ `cat /etc/ssh/sshd_config |grep ^PermitRootLogin|awk '{print $2}'` == "no" ]];then
    ECHO_GREEN "/etc/ssh/sshd_config PermitRootLogin参数已禁用root登录。"
  else
    ECHO_YELLOW "/etc/ssh/sshd_config PermitRootLogin参数未禁用root登录。"
  fi
fi
echo

echo "c) 应及时删除或停用多余的、过期的账户，避免共享账户的存在；"
ECHO_YELLOW "1、系统可登录的用户，需要确认这些用户谁在使用，是否存在多人共享账户的情况。"
echo "$login_user"
echo

echo "d) 应授予管理用户所需的最小权限，实现管理用户的权限分离；"
ECHO_YELLOW "1、是否存在三权账号，安全管理员、审计管理员、系统管理员对应哪些用户。"
echo "$login_user"
echo

echo "e) 应由授权主体配置访问控制策略，访问控制策略规定主体对客体的访问规则；"
ECHO_YELLOW "1、授权主体是哪位管理员"
echo

echo "f) 访问控制的粒度应达到主体为用户级或进程级，客体为文件、数据库表级；"
echo “1、检查/etc/passwd、/etc/profile、应用部署目录、数据库安装目录跟数据库存储目录，权限设置是否合理，”
echo

echo "g) 应对重要主体和客体设置安全标记，并控制主体对有安全标记信息资源的访问。"
echo "1、检查SELINUX是否开启"
if [[ `cat /etc/selinux/config|grep ^SELINUX|head -n 1|awk -F= '{print $2}'` == "disabled" ]];then
  ECHO_YELLOW "SELINUX已禁用。"
else
  ECHO_WHITE "SELINUX状态:`getenforce`"
fi
echo

sleep 1
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>安全审计<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "a) 应启用安全审计功能，审计覆盖到每个用户，对重要的用户行为和重要安全事件进行审计；"
echo "1、检查rsyslog和auditd进程是否开启"
ps -ef |egrep "auditd|rsyslog"|grep -v grep|grep -v "\[k"
echo 

echo "b) 审计记录应包括事件的日期和时间、用户、事件类型、事件是否成功及其他与审计相关的信息；"
echo "默认符合"
echo

echo "c) 应对审计记录进行保护，定期备份，避免受到未预期的删除、修改或覆盖等；"
echo "1、检查audit审计日志是否满足180天"
#寻找最老的audit文件
audit_log_file=`ls /var/log/audit|tail -n 1`
cd /var/log/audit/
log_first_timestamp=`head ${audit_log_file} |head -n 1|awk '{print $2}'|awk -F [\(:] '{print $2}'|awk -F '.' '{print $1}'`
log_format_time=`date -d@${log_first_timestamp} +"%Y-%m-%d %H:%M:%S"`
now_timestamp=`date +%s`
stamp_diff=`expr $now_timestamp - $log_first_timestamp`
day_diff=`expr $stamp_diff / 86400`
echo "/var/log/audit/${audit_log_file}日志文件的最早时间为: ${log_format_time},留存有${day_diff}天。"

if [[ ${day_diff} -ge 180 ]];then
  ECHO_GREEN "日志留存满足180天，符合国家法律法规。"
  else
  ECHO_RED "日志留存不满足180天，不符合国家法律法规。"
fi
echo

echo "2、检查审计日志是否外发"
regex_ip="(2[0-4][0-9]|25[0-5]|1[0-9][0-9]|[1-9]?[0-9])(\.(2[0-4][0-9]|25[0-5]|1[0-9][0-9]|[1-9]?[0-9])){3}"
cat /etc/rsyslog.conf | grep -v "^#"|egrep -o "$regex_ip" 
if [ $? == 0 ];then
  ECHO_GREEN "/etc/rsyslog.conf已开启外发"
  ECHO_WHITE "外发IP为${regex_ip}"
else
  ECHO_YELLOW "/etc/rsyslog.conf未开启外发"
fi
echo

echo "d) 应对审计进程进行保护，防止未经授权的中断。"
echo "默认符合"
echo 


echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>入侵防范<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "a) 应遵循最小安装的原则，仅安装需要的组件和应用程序；"
echo "1、需查看yum list installed命令执行结果进行确认,文件结尾查看"
echo

echo "b) 应关闭不需要的系统服务、默认共享和高危端口；"
#高危端口 https://support.huawei.com/enterprise/zh/doc/EDOC1100297669/fc44a7df
echo "1、检查是否开启了高危端口"
ss -tunlp|egrep ":20|:21|:111|:135|:137|:138|:139|:445|:69|:5900|:5901|:5902|:512|:513|:514"
netstat -tnlp
echo

echo "2、已开启系统服务，systemctl list-units --type=service 文件结果查看"
echo

echo "c）应通过设定终端接入方式或网络地址范围对通过网络进行管理的管理终端进行限制；"
echo "1、/etc/hosts.allow、/etc/hosts.deny文件是否有做配置"
filelist2="/etc/hosts.deny /etc/hosts.allow"
for file in ${filelist2}
do
  if [[ `cat ${file}|egrep -v "#"|wc -l` -eq 0 ]];then
    ECHO_YELLOW "$file文件条目为0，未进行任何配置。"
    else
    ECHO_GREEN "$file文件条目不为0，已进行任何配置。"
  fi
done

echo "2、检查iptable/firewall条目"
iptables -L -nv --line-number
#firewall-cmd --list-all-zones
#firewall-cmd --zone=public --list-ports
echo

echo "d) 应提供数据有效性检验功能，保证通过人机接口输入或通过通信接口输入的内容符合系统设定要求；"
echo "不适用"
echo

echo "e) 应能发现可能存在的已知漏洞，并在经过充分测试评估后，及时修补漏洞；"
echo "经漏洞扫描，服务器未发现高风险漏洞。"
echo

echo "f) 应能够检测到对重要节点进行入侵的行为，并在发生严重入侵事件时提供报警。"
ECHO_YELLOW "需要检查主机是否有安装防入侵的软件，软件版本是多少，更新规则是什么样子，是否提供告警"
echo

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>恶意代码防范<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "应采用免受恶意代码攻击的技术措施或主动免疫可信验证机制及时识别入侵和病毒行为，并将其有效阻断。"
ECHO_YELLOW "需要检查主机是否有安装防病毒的软件，软件版本是多少，更新规则是什么样子，是否可以阻断"
echo

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>可信验证<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "可基于可信根对计算设备的系统引导程序、系统程序、重要配置参数和应用程序等进行可信验证，并在应用程序的关键执行环节进行动态可信验证，在检测到其可信性受到破坏后进行报警，并将验证结果形成审计记录送至安全管理中心。"
echo "不适用"


echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>数据完整性<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "a) 应采用校验技术或密码技术保证重要数据在传输过程中的完整性，包括但不限于鉴别数据、重要业务数据、重要审计数据、重要配置数据、重要视频数据和重要个人信息等；"
ECHO_GREEN "经核查，服务器使用SSH协议进行管理，可以保证数据在传输过程中的完整性。"
echo

echo "b) 应采用校验技术或密码技术保证重要数据在存储过程中的完整性，包括但不限于鉴别数据、重要业务数据、重要审计数据、重要配置数据、重要视频数据和重要个人信息等。"
str=`cat /etc/shadow|grep ^root|awk -F: '{print $2}'|cut  -b 1-3`
encryption_type=""

if [[ ${str} == '$1$' ]];then
  encryption_type="MD5"
elif [[ ${str} == '$2$' ]];then
  encryption_type="Blowfish"
elif [[ ${str} == '$5$' ]];then
  encryption_type="SHA-256"
elif [[ ${str} == '$6$' ]];then
  encryption_type="SHA-512"
else
  encryption_type="未知加密算法"
fi

if [[ $encryption_type == 'MD5' || $encryption_type == "未知加密算法" ]];then
  ECHO_YELLOW "经核查，服务器鉴别信息使用${encryption_type}进行加密，并存储在shadow文件中，且不存在重要配置数据，无法保证数据在存储过程中的完整性。"
else
  ECHO_GREEN "经核查，服务器鉴别信息使用${encryption_type}进行加密，并存储在shadow文件中，且不存在重要配置数据，可以保证数据在存储过程中的完整性。"
fi
echo


echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>数据保密性<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "a) 应采用密码技术保证重要数据在传输过程中的保密性，包括但不限于鉴别数据、重要业务数据和重要个人信息等；"
ECHO_GREEN "经核查，服务器使用SSH协议进行管理，可以保证数据在传输过程中的保密性。"
echo

echo "b) 应采用密码技术保证重要数据在存储过程中的保密性，包括但不限于鉴别数据、重要业务数据和重要个人信息等。"
if [[ $encryption_type == 'MD5' || $encryption_type == "未知加密算法" ]];then
  ECHO_YELLOW "经核查，服务器鉴别信息使用${encryption_type}进行加密，并存储在shadow文件中，且不存在重要配置数据，无法保证数据在存储过程中的保密性。"
else
  ECHO_GREEN "经核查，服务器鉴别信息使用${encryption_type}进行加密，并存储在shadow文件中，且不存在重要配置数据，可以保证数据在存储过程中的保密性。"
fi
echo


echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>数据备份恢复<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "a) 应提供重要数据的本地数据备份与恢复功能；"
ECHO_YELLOW "服务器是否存在重要数据，备份如何做的，增量备份还是全量备份，保留最近多少天的备份。"
echo

echo "b) 应提供异地实时备份功能，利用通信网络将重要数据实时备份至备份场地；"
ECHO_YELLOW "备份是否有异地备份"
echo

echo "c) 应提供重要数据处理系统的热冗余，保证系统的高可用性。"
ECHO_YELLOW "服务器是否热冗余部署"
echo


echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>剩余信息保护<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "a) 应保证鉴别信息所在的存储空间被释放或重新分配前得到完全清除；"
ECHO_GREEN "经核查，系统在退出登录后无法回退，能够保证鉴别信息所在的存储空间被释放或重新分配前得到完全清除。"
echo

echo "b) 应保证存有敏感数据的存储空间被释放或重新分配前得到完全清除。"
echo "1、检查HISTSIZE变量值是否是0"
if [[ ${HISTSIZE} == 0 ]];then
  ECHO_GREEN "经核查more /etc/profile命令，HISTSIZE已设置为0。"
else
  ECHO_YELLOW "经核查more /etc/profile命令，HISTSIZE未设置为0，当前值是${HISTSIZE}。"
fi
echo


echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>个人信息保护<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "a) 应仅采集和保存业务必需的用户个人信息；"
echo "经核查，服务器不涉及个人信息，此项不适用。"
echo

echo "b) 应禁止未授权访问和非法使用用户个人信息。"
echo "经核查，服务器不涉及个人信息，此项不适用。"
echo

sleep 3
ECHO_INFO "##########################其他附加信息##############################################"
ECHO_INFO "######系统基本信息#######"
hostname=$(uname -n)
system=$(cat /etc/os-release | grep "^NAME" | awk -F\" '{print $2}')
version=$(cat /etc/redhat-release | awk '{print $4$5}')
kernel=$(uname -r)
platform=$(uname -p)
address=$(ip addr | grep inet | grep -v "inet6" | grep -v "127.0.0.1" | awk '{ print $2; }' | tr '\n' '\t' )
cpumodel=$(cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq)
cpu=$(cat /proc/cpuinfo | grep 'processor' | sort | uniq | wc -l)
machinemodel=$(dmidecode | grep "Product Name" | sed 's/^[ \t]*//g' | tr '\n' '\t' )
date=$(date)

echo "主机名:           $hostname"
echo "系统名称:         $system"
echo "系统版本:         $version"
echo "内核版本:         $kernel"
echo "系统类型:         $platform"
echo "本机IP地址:       $address"
echo "CPU型号:          $cpumodel"
echo "CPU核数:          $cpu"
echo "机器型号:         $machinemodel"
echo "系统时间:         $date"
echo


ECHO_INFO "######系统资源使用情况#######"
summemory=$(free -h |grep "Mem:" | awk '{print $2}')
freememory=$(free -h |grep "Mem:" | awk '{print $4}')
usagememory=$(free -h |grep "Mem:" | awk '{print $3}')
uptime=$(uptime | awk '{print $2" "$3" "$4" "$5}' | sed 's/,$//g')
loadavg=$(uptime | awk '{print $9" "$10" "$11" "$12" "$13}')

echo "总内存大小:           $summemory"
echo "已使用内存大小:       $usagememory"
echo "可使用内存大小:       $freememory"
echo "系统运行时间:         $uptime"
echo "系统负载:             $loadavg"
echo
ECHO_INFO "######系统资源使用情况#######"
echo

ECHO_INFO "######磁盘信息#######"
echo "##fdisk -l##"
fdisk -l
echo
echo "##df -hi##"
df -hi
echo
echo "##cat /etc/fstab##"
cat /etc/fstab
echo
ECHO_INFO "######磁盘信息#######"
echo


ECHO_INFO "######进程信息#######"
echo "##ps -ef##"
ps -ef
echo
ECHO_INFO "######进程信息#######"
echo

ECHO_INFO "######计划任务信息#######"
echo "##crontab -l##"
crontab -l
echo
echo "##cat /etc/crontab##"
cat /etc/crontab 
ECHO_INFO "######计划任务信息#######"
echo

ECHO_INFO "######防火墙#######"
echo "##iptables -L -nv --line-number##"
iptables -L -nv --line-number
echo
echo "##firewall-cmd --list-all-zones##"
firewall-cmd --list-all-zones
echo
echo "##firewall-cmd --zone=public --list-ports##"
firewall-cmd --zone=public --list-ports
echo
ECHO_INFO "######防火墙#######"
echo


ECHO_INFO "######查看已安装的软件包#######"
echo "##yum list installed##"
yum list installed
echo
echo "##rpm -qa##"
rpm -qa
ECHO_INFO "######查看已安装的软件包#######"
echo


ECHO_INFO "######用户相关文件#######"
echo "##cat /etc/passwd##"
cat /etc/passwd
echo
echo "##cat /etc/shadow##"
cat /etc/shadow
echo
echo "##cat /etc/gruop##"
cat /etc/gruop
echo
echo "##cat /etc/gshadow##"
cat /etc/gshadow
echo
ECHO_INFO "######用户相关文件#######"


ECHO_INFO "######端口连接状态#######"
echo "##netstat -tnlpa##"
netstat -tnlpa
echo
echo "##ss -tnlpa##"
ss -tnlpa
echo "##netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'##"
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}' 
ECHO_INFO "######端口连接状态#######"
echo


ECHO_INFO "######其他文件#######"
echo "##cat /etc/logrotate.conf##"
cat /etc/logrotate.conf
echo
echo "##cat /etc/pam.d/system-auth##"
cat /etc/pam.d/system-auth
echo "##cat /etc/security/pwquality.conf##"
cat /etc/security/pwquality.conf
echo
echo "##cat /etc/bashrc##"
cat /etc/bashrc
echo
echo "##cat /etc/login.defs##"
cat /etc/login.defs 
echo
echo "##cat /etc/pam.d/sshd##"
cat /etc/pam.d/sshd 
echo "##cat /etc/ssh/sshd_config##"
cat /etc/ssh/sshd_config
echo
echo "##cat /etc/sysctl.conf##"
cat /etc/sysctl.conf 
echo
echo "##cat /root/.bashrc##"
cat /root/.bashrc
echo
ECHO_INFO "######其他文件#######"
echo


ECHO_INFO "######其他命令#######"
echo "##lastb##"
lastb
echo

echo "##lastlog##"
lastlog
echo
ECHO_INFO "######其他命令#######"
ECHO_INFO "####################################################################################"
echo

















sleep 1
timer_end=`date "+%Y-%m-%d %H:%M:%S"`
duration=`echo $(($(date +%s -d "${timer_end}") - $(date +%s -d "${timer_start}"))) | awk '{t=split("60 s 60 m 24 h 999 d",a);for(n=1;n<t;n+=2){if($1==0)break;s=$1%a[n]a[n+1]s;$1=int($1/a[n])}print s}'`
ECHO_INFO "开始时间: $timer_start"
ECHO_INFO "结束时间: $timer_end"
ECHO_INFO "耗时: $duration"


#!/bin/bash
# 执行示例：
# ./luoge_dengbao.sh > luoge_dengbao__`hostname`.txt
set +e
set -x

echo "执行命令: cat /etc/redhat-release"
cat /etc/redhat-release
echo "执行命令: date"
date
echo "执行命令: cat /etc/shadow"
cat /etc/shadow
echo "执行命令: cat /etc/pam.d/system-auth"
cat /etc/pam.d/system-auth
echo "执行命令: cat /etc/login.defs"
cat /etc/login.defs
echo "执行命令: cat /etc/profile"
cat /etc/profile
echo "执行命令: netstat -ntulp"
netstat -ntulp
echo "执行命令: cat /etc/hosts.deny"
cat /etc/hosts.deny
echo "执行命令: cat /etc/hosts.allow"
cat /etc/hosts.allow
echo "执行命令: iptables -L -n -v"
iptables -L -n -v
echo "执行命令: cat /etc/ssh/sshd_config | grep PermitRootLogin"
cat /etc/ssh/sshd_config | grep PermitRootLogin
echo "执行命令: cat /etc/sudoers"
cat /etc/sudoers
echo "执行命令: ls -l /var/log"
ls -l /var/log
echo "执行命令: ls -l /var/log/audit"
ls -l /var/log/audit
echo "执行命令: ls -l /etc/rsyslog.conf"
ls -l /etc/rsyslog.conf
echo "执行命令: ls -l /etc/audit/auditd.conf"
ls -l /etc/audit/auditd.conf
echo "执行命令: service auditd status"
service auditd status
echo "执行命令: service rsyslog status"
service rsyslog status
echo "执行命令: service syslog status"
service syslog status
echo "执行命令: cat /etc/audit/audit.rules"
cat /etc/audit/audit.rules
echo "执行命令: cat /etc/rsyslog.conf"
cat /etc/rsyslog.conf
echo "执行命令: cat /etc/rsyslog.d/50-default.conf"
cat /etc/rsyslog.d/50-default.conf
echo "执行命令: cat /etc/logrotate.conf"
cat /etc/logrotate.conf
echo "执行命令: crontab -l"
crontab -l
echo "执行命令: systemctl list-units --type=service | grep running"
systemctl list-units --type=service | grep running
echo "执行命令: service --status-all"
service --status-all
echo "执行命令: cat /etc/profile|grep HISTSIZE"
cat /etc/profile|grep HISTSIZE

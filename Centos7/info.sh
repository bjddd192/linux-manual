#!/bin/bash

echo "sudo cat /etc/passwd" >> info.txt
echo "********* start *************" >> info.txt
sudo cat /etc/passwd >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "sudo cat /etc/shadow" >> info.txt
echo "********* start *************" >> info.txt
sudo cat /etc/shadow >> info.txt
echo -e "********* end *************\n\n" >> info.txt

echo "cat /etc/group" >> info.txt
echo "********* start *************" >> info.txt
sudo cat /etc/group >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /etc/login.defs" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/login.defs >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /etc/pam.d/system-auth" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/pam.d/system-auth >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /etc/ssh/sshd_config" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/ssh/sshd_config >> info.txt
echo -e "********* end *************\n\n" >> info.txt



echo "cat /etc/securetty" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/securetty >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /etc/rsyslog.conf" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/rsyslog.conf   >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /etc/logrotate.conf" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/logrotate.conf  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /etc/redhat-release" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/redhat-release  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /proc/version" >> info.txt
echo "********* start *************" >> info.txt
cat /proc/version  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /etc/hosts.allow" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/hosts.allow >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /etc/hosts.deny" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/hosts.deny  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /etc/profile" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/profile  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "cat /etc/security/limits.conf" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/security/limits.conf  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "ls -l /var/log" >> info.txt
echo "********* start *************" >> info.txt
ls -l /var/log  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "tail -n 20 /var/log/messages" >> info.txt
echo "********* start *************" >> info.txt
tail -n 20 /var/log/messages  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "head -20 /var/log/secure" >> info.txt
echo "********* start *************" >> info.txt
head -20 /var/log/secure  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "tail -n 20 /var/log/secure" >> info.txt
echo "********* start *************" >> info.txt
tail -n 20 /var/log/secure  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "head -20 /var/log/audit/audit.log" >> info.txt
echo "********* start *************" >> info.txt
head -20 /var/log/audit/audit.log  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "tail -n 20 /var/log/audit/audit.log" >> info.txt
echo "********* start *************" >> info.txt
tail -n 20 /var/log/audit/audit.log  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "ls -l /etc/passwd  " >> info.txt
echo "********* start *************" >> info.txt
ls -l /etc/passwd   >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "ls -l /etc/group" >> info.txt
echo "********* start *************" >> info.txt
ls -l /etc/group >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "ls -l /etc/shadow" >> info.txt
echo "********* start *************" >> info.txt
ls -l /etc/shadow  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "ls -l /var/log/messages" >> info.txt
echo "********* start *************" >> info.txt
ls -l /var/log/messages   >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "ls -l /var/log/secure " >> info.txt
echo "********* start *************" >> info.txt
ls -l /var/log/secure  >> info.txt
echo -e "********* end *************\n\n" >> info.txt

echo "cat /etc/audit/audit.rules" >> info.txt
echo "********* start *************" >> info.txt
cat /etc/audit/audit.rules  >> info.txt
echo -e "********* end *************\n\n" >> info.txt

echo "ls -l /var/log/audit/audit.log" >> info.txt
echo "********* start *************" >> info.txt
ls -l /var/log/audit/audit.log  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "ps -ef | grep ssh " >> info.txt
echo "********* start *************" >> info.txt
ps -ef | grep ssh   >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "ps -ef | grep telnet " >> info.txt
echo "********* start *************" >> info.txt
ps -ef | grep telnet   >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "ps -ef | grep ftp  " >> info.txt
echo "********* start *************" >> info.txt
ps -ef | grep ftp    >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "ps -ef | grep rlogin" >> info.txt
echo "********* start *************" >> info.txt
ps -ef | grep rlogin  >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "systemctl | grep running" >> info.txt
echo "********* start *************" >> info.txt
systemctl | grep running >> info.txt
echo -e "********* end *************\n\n" >> info.txt


echo "netstat -ntlp" >> info.txt
echo "********* start *************" >> info.txt
netstat -ntlp  >> info.txt
echo -e "********* end *************\n\n" >> info.txt

echo "crontab -l" >> info.txt
echo "********* start *************" >> info.txt
crontab -l  >> info.txt
echo -e "********* end *************\n\n" >> info.txt




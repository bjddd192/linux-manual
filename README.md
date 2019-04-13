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
```


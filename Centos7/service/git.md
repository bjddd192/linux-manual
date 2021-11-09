## Git 操作记录

### 配置多个ssh key

```sh
# 生成一个自定义用的 SSH-Key
ssh-keygen -t rsa -C "yang.lei@belle.com.cn" -f ~/.ssh/id_ed25519
# 添加私钥
ssh-add ~/.ssh/id_ed25519
# 查看私钥列表
ssh-add -l
# 清空私钥列表
# ssh-add -D
```

[git 配置多个SSH keys](https://blog.csdn.net/wangpingtaohn/article/details/74191628)

### 批量删除 tag

```sh
# 查看远程 tag
git show-ref --tag | grep V2019* | awk '{print ":"$2}'

# 批量删远程 tag
git show-ref --tag | grep V2019* | awk '{print ":"$2}' | xargs git push origin 
# 批量删远程 tag(只保留300个tag)
count=`git show-ref --tag | wc -l` && count=$[$count-300] && [[ $count -gt 0 ]] && git show-ref --tag | awk "NR<=$count{print}" | awk '{print ":"$2}' | xargs git push origin 

# 查看本地 tag  
git tag -l | grep V2019*

# 批量删本地 tag
git tag -l | grep V2019* | xargs git tag -d
# 批量删本地 tag(只保留300个tag)
count=`git tag -l | wc -l` && count=$[$count-300] && [[ $count -gt 0 ]] && git tag -l | awk "NR<=$count{print}" | xargs git tag -d

# 先删远端，再删除本地 

# 批量删本地所有 tag
git tag -l | xargs git tag -d
# 从远程拉取所有 tag
git fetch origin --prune 

# 删除远程标签时遇到的问题
# 起因： 由于每次上线都会打一个标签，因此标签库存在多个标签。想要删除全部的无效标签。 结果执行完毕删除远程标签和删除本地标签后。 发现其他同事再次推送的时候， 删除的那些标签又莫名其妙的回来了。
# 原因: 这是因为其他同事的本地标签没有清理，这时候就必须要其他同事全部都要清理本地的标签。 (很显然这行不通，很难。)
# 解决办法：
git tag -l | grep V2019 | xargs -n 1 git push --delete origin
```

#### 参考资料

[git同步远程tag(远程tags删除了但本地一直在)，sourcetree自定义操作](https://www.jianshu.com/p/06341eca64aa)
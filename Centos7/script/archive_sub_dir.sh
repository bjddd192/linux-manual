#!/bin/bash
# 归档TMS签收图片

# 指定源目录和目标目录
src_dir="/data/scm-tms-signImgs"
dest_dir="/var/lib/container/scm-tms-signImgs"

# 遍历源目录下所有子目录
for dir in "$src_dir"/* ; do	
    # 获取子目录名（去除路径）
    subdir=$(basename "$dir")
    if [[ $subdir == 2018* ]]; then
        echo $subdir
        # 创建当前子目录内容的tar.gz压缩包，并写入目标目录
        cd "$dir"
        tar -czf "${dest_dir}/${subdir}.tar.gz" .
   fi
done

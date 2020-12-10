if [ `dmidecode -s system-product-name | grep  OpenStack | wc -l` -eq 0 ];then
        yum install fio sysbench memtester -y > /dev/null 2>&1&

        #cpu
        threadnum=`cat /proc/cpuinfo|grep processor|wc -l`
        sysbench cpu --cpu-max-prime=20000 --threads="${threadnum}" run > /tmp/result-cpu1.txt

        #io
        if [ ! -e /data ];then
                mkdir -p /data
        fi
        /usr/bin/fio -filename=/data/fio_8k -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=libaio -bs=8k -size=32G -numjobs="${threadnum}" -runtime=600 -group_reporting -name=mytest -ioscheduler=noop >/tmp/result-io1.txt

        #memory
       /usr/bin/memtester 2048M 1 > /tmp/result-mem.txt 

fi
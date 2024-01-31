#!/bin/bash
source . /etc/profile  ~/.bash_profile


function __pre_set__ ()
{
	#颜色
	WHITE_COLOR="\E[1;37m"
	RED_COLOR="\E[1;31m"
	BLUE_COLOR='\E[1;34m'
	GREEN_COLOR="\E[1;32m"
	YELLOW_COLOR="\E[1;33m"
	RES="\E[0m"

	#设置日志路径
	temp_log="/tmp/mysql_db_create.log"
	hist_log="/tmp/mysql_db_create_hist.log"


	#清除临时日志
	> ${temp_log}

	#分割长期日志
	echo >> ${hist_log}


	function echo_info () 
	{
		[ $# -ne 1 ] && return 1
		CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
		printf "${GREEN_COLOR}${CURRENT_TIME} [INFO]:${RES} ${GREEN_COLOR}$1${RES}\n"
		printf "${CURRENT_TIME} [INFO]: $1 \n" >> $temp_log 2>&1
		printf "${CURRENT_TIME} [INFO]: $1 \n" >> $hist_log 2>&1
	}


	function echo_warn ()
	{
		[ $# -ne 1 ] && return 1
		CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
		printf "${YELLOW_COLOR}${CURRENT_TIME} [WARN]:${RES} ${YELLOW_COLOR}$1${RES}\n"
		printf "${CURRENT_TIME} [INFO]: $1 \n" >> $temp_log 2>&1
		printf "${CURRENT_TIME} [INFO]: $1 \n" >> $hist_log 2>&1	
	}

	function echo_error () 
	{
		[ $# -ne 1 ] && return 1
		CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
		printf "${RED_COLOR}${CURRENT_TIME} [ERROR]:${RES} ${RED_COLOR}$1${RES}\n"
		printf "${CURRENT_TIME} [INFO]: $1 \n" >> $temp_log 2>&1
		printf "${CURRENT_TIME} [INFO]: $1 \n" >> $hist_log 2>&1	
	}

	function echo_parameter () 
	{
		[[ $# -ne 1 ]] && return 1
		printf "${WHITE_COLOR}$1${RES}\n"
		printf "${CURRENT_TIME} [INFO]: $1 \n" >> $temp_log 2>&1
		printf "${CURRENT_TIME} [INFO]: $1 \n" >> $hist_log 2>&1	
	}

}

function  __pre_check__()
{

	##检查当前用户是否为root 
	[[ $USER != root ]] && echo_error "The current login user is not root. Please execute this script with root "  && exit 1

	#检测mysql命令是否存在
	which mysql       > /dev/null || (echo_error "mysql  don't exists, please check!!!"  && exit 1)
	which mysqld      > /dev/null || (echo_error "mysqld don't exists, please check!!!"  && exit 1)
	which mysqld_safe > /dev/null || (echo_error "mysqld_safe don't exists, please check!!!"  && exit 1)
	[[ ! -f /usr/local/mysql/support-files/mysql.server ]] && echo_error "/usr/local/mysql/support-files/mysql.server don't exists, please check!!!"  && exit 1
}

function  __help__()
{
	echo
	echo
	echo "Usage:"
	echo "    /bin/bash mysql_db_create.sh keyword=value"
	echo "----------------------------------------------------------------------------------"
	echo
	echo "keyword:"
	echo "  -h                     -- Print help information"
	echo "  port=value             -- Specify the database name, example: port=orcl "	
	echo "  data_dir=value         -- Specify database data directory, example: data_dir=/data "
	echo "  innodb_buffer=value    -- Specify the size of the database innodb_buffer, example: innodb_buffer=2G "
	echo "  pass=value             -- Set passwords for default user: root and admin, example: pass=mysql "
	exit 1
}

function  __option__()
{

	numargs=$#

	for ((i = 1; i <= $numargs; i++))   
	do
		j=$1 

		case $j in
		-h)
			__help__
		;;
		
		port*)
			port=$(echo $j | awk -F = '{print $2}')
			[[ -z $port ]] && echo_error "keyword: \" port \" don't have value, please enter -h for help " && exit 1
		;;
		
		data_dir*)
			data_dir=$(echo $j | awk -F = '{print $2}')
			[[ -z $data_dir ]] && echo_error "keyword: \" data_dir \" don't have value, please enter -h for help " && exit 1
		;;	
	
		innodb_buffer*)
			innodb_buffer=$(echo $j | awk -F = '{print $2}')  
			[[ -z $innodb_buffer ]] && echo_error "keyword: \" innodb_buffer \" don't have value, please enter -h for help " && exit 1
		;;
		
		pass*)
			pass=$(echo $j | awk -F = '{print $2}')  
			[[ -z $pass ]] && echo_error "keyword: \" pass \" don't have value, please enter -h for help " && exit 1
		;;
		
		*)
			echo_error "keyword: \" $j \" is wrong, please input -h for help " && exit 1
		;;
		esac
		
		shift 1
	done

	#调用参数检查函数
	__option_check__

}

function __option_check__ ()
{

	#检测端口是否指定 
	[[ -z ${port} ]] && echo_error "keyword: 'port' must be have value, common value: 3306 " && exit 1	

	
	#检测端口是否存在
	port_state=$(netstat -tnul|grep ${port})
	[[ -n "${port_state}" ]] && echo_error "the port ${port} has been used." && exit 1
	
	#检测innodb内存参数是否指定
	if [[ -n ${innodb_buffer} ]] 
	then
		innodb_buffer_test=${innodb_buffer%?}
		innodb_buffer_last_char=${innodb_buffer##$innodb_buffer_test}
		
		if [[ ${innodb_buffer_last_char} != g ]] && [[ ${innodb_buffer_last_char} != G ]] && [[ ${innodb_buffer_last_char} != m ]] && [[ ${innodb_buffer_last_char} != M ]]
		then
			echo_error "innodb_buffer value: '$innodb_buffer' unit must be identified: g, G, m, M" 
			exit 1
		fi

		if [[ ${innodb_buffer_test} == *[!0-9]* ]]
		then
			echo_error "innodb_buffer value: '$innodb_buffer' must be a number "  
			exit 1
		fi
	else
		#调整内存缓存大小 初始化为内存的60%
		MemTotal=$(cat /proc/meminfo| grep ^MemTotal|awk '{print $2}')
		innodb_buffer=$(echo ${MemTotal} | awk '{printf ("%.0f\n",$1*0.6/1024)}')M
	fi

	
	#设置默认参数
	[[ -z ${pass} ]] && pass=dba#mysql
	[[ -z ${data_dir} ]] && data_dir=/data
}

function __config__ ()
{
	#mysql命令路径
	if   [[ -x /usr/bin/mysql ]]  
	then
		mysql=/usr/bin/mysql 
	elif [[ -x /usr/local/mysql/bin/mysql ]] 
	then
		mysql=/usr/local/mysql/bin/mysql
	else
		echo_error "mysql  don't exists, please check!!!"
		exit 1
	fi

	#设置环境变量
	grep "alias mysql='mysql -h127.0.0.1 --prompt="  /etc/profile  > /dev/null 
	[[ $? != 0 ]] && echo "alias mysql='mysql -h127.0.0.1 --prompt=\"\\u@\\d\\R:\\m>\"'  " >> /etc/profile	
	source /etc/profile	
	

	mysql_data_dir=${data_dir}/mysql/mysql${port}

	#检查数据目录下是否有其他文件存在
	if [[ -d ${mysql_data_dir}/data ]] && [[ $(ls -A ${mysql_data_dir}/data|wc -l) != 0 ]] 
	then
		echo_error "datadir ${mysql_data_dir}/data is not empty, please check!!!"
		exit 1
	fi

	#创建基础目录
	if [[ ! -d ${mysql_data_dir} ]] 
	then
		mkdir -p ${mysql_data_dir}
		[[ $? != 0 ]] && echo_error "failed command: mkdir -p ${mysql_data_dir} " && exit 1
	fi

	#创建子目录
	cd ${mysql_data_dir} && mkdir -p data conf logs/binlog logs/relay logs/slow logs/error 
	[[ $? != 0 ]] && echo_error "failed command: cd ${mysql_data_dir} && mkdir -p data conf logs/binlog logs/relay logs/slow logs/error  " && exit 1

	
	#创建备份目录
	mkdir -p -m 777 /data/backup
	[[ $? != 0 ]] && echo_error "failed command: mkdir -p -m 777 /data/backup" && exit 1

	#修改目录属主属组
	chown -R  mysql.mysql /data/mysql

	#生成server_id
	[[ -z $server_id ]] && server_id=$(echo $RANDOM | cut -c 1-10)
	[[ -z $server_id ]] && server_id=$(awk 'BEGIN{srand();print rand()*1000000}')
	
	
	conf_file="${mysql_data_dir}/conf/mysql${port}.cnf"
	ctrl_file="/etc/init.d/mysqld${port}"
	
	
	#打印配置参数
	echo_parameter  "[database parameters with values:]"
	echo_parameter  "port                   = ${port}"
	echo_parameter  "pass                   = *******"
	echo_parameter  "data_dir               = ${data_dir}"
	echo_parameter  "innodb_buffer          = ${innodb_buffer}"
	echo_parameter  "config_file            = ${conf_file}"
	echo_parameter  "contrl_file            = ${ctrl_file}"

}

function  __mysql_cnf__ ()
{

	echo_info "create mysql config file ............................."
	
	echo "
	[client]
	#port                                                   = ${port}
	#default_character_set                                  = utf8
	#socket                                                 = ${mysql_data_dir}/data/mysql.sock
	#prompt                                                 = \\u@\\d\\R:\\m>

	[mysqld]                                               
	#-----FILE---------#
	basedir                                                = /usr/local/mysql
	datadir                                                = ${mysql_data_dir}/data       #mysql数据存放目录   禁止修改
	pid_file                                               = ${mysql_data_dir}/data/mysql.pid	
	tmpdir                                                 = ${mysql_data_dir}/data
	innodb_tmpdir                                          = ${mysql_data_dir}/data
	socket                                                 = ${mysql_data_dir}/data/mysql.sock
	log_bin                                                = ${mysql_data_dir}/logs/binlog/binlog    #是否要启用binlog，视具体需求而定
	relay_log                                              = ${mysql_data_dir}/logs/relay/relaylog   #relay log 路径 禁止修改
	slow_query_log_file                                    = ${mysql_data_dir}/logs/slow/slow.log 
	log_error                                              = ${mysql_data_dir}/logs/error/error.log 
	
	#-----GENERAL------#                                   
	user                                                   = mysql
	port                                                   = ${port}	
	default_storage_engine                                 = InnoDB
	character_set_server                                   = utf8
	lower_case_table_names                                 = 1
	explicit_defaults_for_timestamp                        = true
	symbolic_links                                         = 0
	log_timestamps                                         = SYSTEM
	#skip_slave_start                                      
	#validate_password_policy                              = 0

	
	#-----MyISAM------#                                    
	key_buffer_size                                        = 512M

	
	#-----SAFETY------#                                    
	max_allowed_packet                                     = 128M
	max_connect_errors                                     = 1000000
	skip_name_resolve                                      


	#-----BINARY LOGGING-----#                             
	server_id                                              = ${server_id} 
	binlog_format                                          = ROW
	expire_logs_days                                       = 7     #binlog 保留时间，视具体需求而定
	sync_binlog                                            = 0
	binlog_cache_size                                      = 16M
	max_binlog_cache_size                                  = 4G
	max_binlog_size                                        = 512M
	log_slave_updates                                      = 1
	loose-binlog_transaction_dependency_tracking           = WRITESET
	loose-transaction_write_set_extraction                 = XXHASH64
	slave_parallel_type                                    = LOGICAL_CLOCK
	slave_parallel_workers                                 = 32
	slave_pending_jobs_size_max                            = 128M
	slave_preserve_commit_order                            = on
	binlog_group_commit_sync_delay                         = 10
	binlog_group_commit_sync_no_delay_count                = 10
	master_info_repository                                 = TABLE
	relay_log_info_repository                              = TABLE
	relay_log_recovery                                     = ON
	slave_type_conversions                                 = ALL_NON_LOSSY
	#loose-rpl_semi_sync_master_enabled                    = on    #如果开启了半同步复制，master需要启用
	#loose-rpl_semi_sync_slave_enabled                     = on    #如果开启了半同步复制，slave需要启用


	#-----GTID-----#                                       
	enforce_gtid_consistency                               = ON
	gtid_mode                                              = ON

	
	#-----replication-----#                                
	slave_net_timeout                                      = 60
	read_only                                              = OFF
	super_read_only                                        = OFF
	
	#-----caches and limits-----#                          
	tmp_table_size                                         = 250M
	max_heap_table_size                                    = 250M
	query_cache_type                                       = 0
	query_cache_size                                       = 0
	max_connections                                        = 2000
	max_user_connections                                   = 1000
	back_log                                               = 1024
	thread_cache_size                                      = 1000
	open_files_limit                                       = 20480
	table_definition_cache                                 = 4096
	table_open_cache                                       = 10000
	table_open_cache_instances                             = 16
	sort_buffer_size                                       = 16M
	max_length_for_sort_data                               = 10240
	join_buffer_size                                       = 16M
	read_rnd_buffer_size                                   = 16M
	group_concat_max_len                                   = 1024000

	#-----INNODB-----#                                     
	transaction_isolation                                  = REPEATABLE-READ
	innodb_flush_method                                    = O_DIRECT
	innodb_log_files_in_group                              = 3
	innodb_log_file_size                                   = 1G
	innodb_log_buffer_size                                 = 32M
	innodb_flush_log_at_trx_commit                         = 2
	innodb_file_per_table                                  = 1
	innodb_undo_log_truncate                               = 1
	innodb_undo_tablespaces                                = 3
	innodb_undo_logs                                       = 128
	innodb_max_undo_log_size                               = 2g 
	innodb_buffer_pool_size                                = ${innodb_buffer}   #mysql单实例情况下配置为总内存的60%
	innodb_buffer_pool_instances                           = 8
	innodb_page_cleaners                                   = 10
	innodb_lru_scan_depth                                  = 1024
	innodb_buffer_pool_chunk_size                          = 1G
	innodb_thread_sleep_delay                              = 40
	innodb_change_buffer_max_size                          = 50
	innodb_adaptive_hash_index                             = 1
	innodb_lock_wait_timeout                               = 10
	innodb_rollback_on_timeout                             = ON
	innodb_print_all_deadlocks                             = 1
	innodb_purge_threads                                   = 4
	innodb_read_io_threads                                 = 8
	innodb_write_io_threads                                = 8
	innodb_io_capacity                                     = 2000   #视磁盘io而定，  sas raid：600~1000，sata ssd：2000~10000， pcie ssd：4000~40000
	innodb_flush_neighbors                                 = 1      #视磁盘类型而定：ssd 配置值为 0，sas raid：1
	#innodb_numa_interleave                                = 1      #视是否开启NUMA，开启需要配置为1，关闭需要配置为0
	#innodb_locks_unsafe_for_binlog                        = 1
	innodb_autoinc_lock_mode                               = 2
	innodb_doublewrite                                     = 1
	#init_connect                                          = 'SET autocommit=0'
	#wait_timeout                                          = 100    #客户端如果未使用连接池技术，需配置此值，如果客户端使用连接池技术，保持默认就行
	#interactive_timeout                                   = 100

	#-----slowlog----#                                            
	log_queries_not_using_indexes                          = 0
	slow_query_log                                         = 1
	long_query_time                                        = 0.5

	#-----others-----#                                     
	sql_mode                                               = NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

	" > ${conf_file}
	[[ $? != 0 ]] && echo_error "create mysql config file failed" && exit 1
	
	
	#消除配置文件每行首空格
	sed -i 's/^\s\+//g' ${conf_file}	

}

function  __mysqld__ ()
{
	
	echo_info "copy mysql control file .............................."
	
	#替换
	sed -i 's/pid-file/pid_file/' /usr/local/mysql/support-files/mysql.server 
	
	#复制mysqld 启动文件
	cp -f /usr/local/mysql/support-files/mysql.server  ${ctrl_file}
	[[ $? != 0 ]] && echo_error "failed command cp -f /usr/local/mysql/support-files/mysql.server " && exit 1
	
	#替换配置文件
	sed -i "s/extra_args=\"\"/extra_args=\"-e ${conf_file////\\/}\"/" ${ctrl_file}
	sed -i "s/mysqld_safe --datadir=\"\$datadir\" --pid_file=\"\$mysqld_pid_file_path\"/mysqld_safe --defaults-file=${conf_file////\\/}/" ${ctrl_file}
}

function  __init_db__ ()
{
	#数据库初始化
	echo_info "initializing mysql database .........................."
	source  /etc/profile /root/.bash_profile 
	
	echo_info "log: ${mysql_data_dir}/logs/error/error.log"
	
	mysqld --defaults-file=${conf_file} --initialize-insecure --user=mysql
	[[ $? != 0 ]] && echo_error "initialize mysql database failed: mysqld --defaults-file=${conf_file} --initialize-insecure --user=mysql" && exit 1
	
	#启动数据库
	echo_info "starting mysql database .............................."	
	if [[ -f ${ctrl_file} ]] 
	then 
		${ctrl_file} start
		[[ $? != 0 ]] && echo_error "start mysql database failed" && exit 1
	else
		echo_error "control file: ${ctrl_file} don't exists " && exit 1
	fi
	
	#数据库账号初始化
	echo_info "creating default users ..............................."	
	source  /etc/profile ~/.bash_profile
	
	echo "
	SET sql_log_bin=0; 

	create database slow;

	alter user 'root'@'localhost' identified by '${pass}';

	create user 'admin'@'%'  identified by '${pass}';
	create user 'repl'@'%'   identified by 'dba#repl';
	create user 'logs'@'%'   identified by 'dba#logs';
	create user 'back'@'%'  identified by 'dba#back';
	create user 'temp'@'127.0.0.1'  identified by '123456' password expire interval 1 day;
	grant all on *.* to 'temp'@'127.0.0.1' with grant option;

	grant all on slow.* to 'logs'@'%' ;
	grant all on *.* to 'admin'@'%' with grant option;
	grant replication slave, replication client on *.* to 'repl'@'%';
	grant super,select, replication slave, replication client on *.* to 'logs'@'%';	
	grant select, reload, super, lock tables, show view, event, replication client,replication slave on *.* to 'back'@'127.0.0.1';

	flush privileges;
	set sql_log_bin=1;"	> /tmp/.mysql_users
	
	cat /tmp/.mysql_users | ${mysql} --socket=${mysql_data_dir}/data/mysql.sock
	[[ $? != 0 ]] && echo_error "creating default users failed" && exit 1
	#rm -f /tmp/.mysql_users
	
	echo_info "restarting mysql database ............................"			
	if [[ -f ${ctrl_file} ]] 
	then 
		${ctrl_file} restart
		[[ $? != 0 ]] && echo_error "restart mysql database failed" && exit 1
	else
		echo_error "control file: ${ctrl_file} don't exists " && exit 1
	fi
	
	echo_info "temporary user: mysql -utemp -p123456 -h127.0.0.1 -P${port}"
	echo_info "Notice: temporary user will expire after 1 day"
	
}

function  main()
{
	__pre_set__
	__pre_check__
	__option__ $*
	__config__
	__mysql_cnf__
	__mysqld__
	__init_db__
	
}


main $*


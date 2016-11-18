#!/bin/bash
. ./versions.txt
. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_dir.sh
. ./include/download.sh
. ./include/get_char.sh
. ./include/memory.sh


apt-get install php-fpm php-common php-dev php-mysql php-gd php-bcmath php-mcrypt php-curl php-xml php-xmlrpc php7.0-dba php-mbstring php-intl php-opcache -y
ln -s /etc/init.d/php7.0-fpm /etc/init.d/php-fpm
systemctl daemon-reload


if [ -e "/etc/php/7.0/fpm/php.ini" ];then
    echo "${CSUCCESS}PHP installed successfully! ${CEND}"
else
    echo "${CFAILURE}PHP install failed, Please Contact the author! ${CEND}"
fi

sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@" /etc/php/7.0/fpm/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' /etc/php/7.0/fpm/php.ini
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' /etc/php/7.0/fpm/php.ini
sed -i 's@^short_open_tag = Off@short_open_tag = On@' /etc/php/7.0/fpm/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' /etc/php/7.0/fpm/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' /etc/php/7.0/fpm/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' /etc/php/7.0/fpm/php.ini
sed -i 's@^post_max_size.*@post_max_size = 100M@' /etc/php/7.0/fpm/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' /etc/php/7.0/fpm/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 600@' /etc/php/7.0/fpm/php.ini
sed -i 's@^;realpath_cache_size.*@realpath_cache_size = 2M@' /etc/php/7.0/fpm/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php/7.0/fpm/php.ini
[ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' /etc/php/7.0/fpm/php.ini

rm /usr/share/php7.0-opcache/opcache/opcache.ini -rf
cat > /usr/share/php7.0-opcache/opcache/opcache.ini << EOF
[opcache]
zend_extension=/usr/lib/php/20151012/opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=$Memory_limit
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=100000
opcache.max_wasted_percentage=5
opcache.use_cwd=1
opcache.validate_timestamps=1
opcache.revalidate_freq=60
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.consistency_checks=0
;opcache.optimization_level=0
opcache.file_cache=/tmp
EOF

rm /etc/php/7.0/fpm/pool.d/www.conf -rf
cat > /etc/php/7.0/fpm/pool.d/www.conf <<EOF
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = warning

emergency_restart_threshold = 30
emergency_restart_interval = 60s
process_control_timeout = 5s
daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[$run_user]
listen = /dev/shm/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = $run_user
listen.group = $run_user
listen.mode = 0666
user = $run_user
group = $run_user

pm = dynamic
pm.max_children = 12
pm.start_servers = 8
pm.min_spare_servers = 6
pm.max_spare_servers = 12
pm.max_requests = 2048
pm.process_idle_timeout = 10s
request_terminate_timeout = 120
request_slowlog_timeout = 0

pm.status_path = /php-fpm_status
slowlog = log/slow.log
rlimit_files = 51200
rlimit_core = 0

catch_workers_output = yes
;env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF

    if [ $Mem -le 3000 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/3/20))@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/3/30))@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/3/40))@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/3/20))@" /etc/php/7.0/fpm/pool.d/www.conf
    elif [ $Mem -gt 3000 -a $Mem -le 4500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 50@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 30@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 20@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 50@" /etc/php/7.0/fpm/pool.d/www.conf
    elif [ $Mem -gt 4500 -a $Mem -le 6500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 60@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 40@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 30@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 60@" /etc/php/7.0/fpm/pool.d/www.conf
    elif [ $Mem -gt 6500 -a $Mem -le 8500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 70@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 50@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 70@" /etc/php/7.0/fpm/pool.d/www.conf
    elif [ $Mem -gt 8500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 80@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 60@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@" /etc/php/7.0/fpm/pool.d/www.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@" /etc/php/7.0/fpm/pool.d/www.conf
    fi

    service php-fpm restart
cd ..
#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_redis-server() {
  apt-get -t jessie-backports install redis-server -y

  echo never > /sys/kernel/mm/transparent_hugepage/enabled
  echo never > /sys/kernel/mm/transparent_hugepage/defrag


  if [ -f "/usr/bin/redis-server" ]; then
    sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' /etc/redis/redis.conf
    sed -i "s@logfile.*@logfile /var/redis.log@" /etc/redis/redis.conf
    sed -i "s@^dir.*@dir /var@" /etc/redis/redis.conf
    sed -i 's@daemonize no@daemonize yes@' /etc/redis/redis.conf
    sed -i "s@^# bind 127.0.0.1@bind 127.0.0.1@" /etc/redis/redis.conf
    redis_maxmemory=`expr $Mem / 8`000000
    [ -z "`grep ^maxmemory /etc/redis/redis.conf`" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr $Mem / 8`000000@" /etc/redis/redis.conf
    echo "${CSUCCESS}Redis-server installed successfully! ${CEND}"
    popd
    service redis-server restart
  else
    rm -rf ${redis_install_dir}
    echo "${CFAILURE}Redis-server install failed, Please contact the author! ${CEND}"
    kill -9 $$
  fi
  popd
}

Install_php-redis() {
  pushd ${oneinstack_dir}/src
  phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    if [ "`${php_install_dir}/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ]; then
      tar xzf redis-${redis_pecl_for_php7_version}.tgz
      pushd redis-${redis_pecl_for_php7_version}
    else
      tar xzf redis-$redis_pecl_version.tgz
      pushd redis-$redis_pecl_version
    fi
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    if [ -f "${phpExtensionDir}/redis.so" ]; then
      echo 'extension=redis.so' > ${php_install_dir}/etc/php.d/ext-redis.ini
      echo "${CSUCCESS}PHP Redis module installed successfully! ${CEND}"
      popd
      rm -rf redis-${redis_pecl_for_php7_version} redis-$redis_pecl_version
    else
      echo "${CFAILURE}PHP Redis module install failed, Please contact the author! ${CEND}"
    fi
  fi
  popd
}

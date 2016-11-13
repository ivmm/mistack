#前言

  MiStack 魔改自 OneinStack，主要区别就是将 jemalloc、boost 这样的依赖软件从自行编译转自使用系统的二进制包文件，可以获得以及有效的安全更新，而不是自行更新。

#特性

1. OpenResty 使用 LibreSSL ； Nginx 使用 OpenSSL 1.1.0
2. 除了 OpenResty、Nginx、PHP、OpenSSL、LibreSSL 其余均依赖二进制包，方便升级
3. 使用最新的 Brotli 压缩方式代替 Gzip

#安装

**注：**此堆栈仅支持 Debian 8 64bit

一、安装 OpenResty，可以新定 SSH 的端口。

```
cat >> /etc/apt/sources.list <<EOF
deb https://mirror.tuna.tsinghua.edu.cn/debian jessie main contrib non-free
deb https://mirror.tuna.tsinghua.edu.cn/debian jessie-proposed-updates main contrib non-free
deb https://mirror.tuna.tsinghua.edu.cn/debian jessie-updates main contrib non-free
deb https://mirror.tuna.tsinghua.edu.cn/debian jessie-backports main contrib non-free
deb https://mirror.tuna.tsinghua.edu.cn/debian-security/ jessie/updates main non-free contrib
EOF

apt-get install git -y
git clone https://github.com/ivmm/mistack.git
cd mistack
chmod +x *.sh
chmod +x ./include/*.sh
chmod +x ./include/*.py
./install.sh 
```

三、安装 Mysql，这里推荐安装 Percona。

```
wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb
dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb
cat >> /etc/apt/percona-release.list <<EOF
deb https://mirror.tuna.tsinghua.edu.cn/percona/apt jessie main
EOF
apt-get update
apt-get install percona-server-server-5.7 -y
service mysql start #启动 Percona
```

即可安装 Percona 5.7，然后进行置

```
mysql_secure_installation # 进行安全设置，除了重置密码其他全部 y 即可

Enter current password for root (enter for none):
解释：输入当前 root 用户密码，输入上面的 root 临时面膜。
Set root password? [Y/n]  y
解释：要设置 root 密码吗？输入 y 表示愿意。
Remove anonymous users? [Y/n]  y
解释：要移除掉匿名用户吗？输入 y 表示愿意。
Disallow root login remotely? [Y/n]  y
解释：不想让 root 远程登陆吗？输入 y 表示愿意。
Remove test database and access to it? [Y/n]  y
解释：要去掉 test 数据库吗？输入 y 表示愿意。
Reload privilege tables now? [Y/n]  y
解释：想要重新加载权限吗？输入 y 表示愿意。
```



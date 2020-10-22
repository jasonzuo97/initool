#!/bin/bash
#2020/10/16 v1.4
#author:佐旭东

ipf=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}' | head -1)

#mysql密码，默认账户为root
mysqlpasswd=troila@123
#mysql端口号
mysqlport=3300

#nginx端口号
nginxport=80

#redis端口号
redisport=6379
#redis默认密码
redispasswd=troila@123

#influxdb端口号
influxdbport=8086
#influxdb默认数据库
influxdbdb=hermes
#influxdb默认用户名
influxdbadmin=admin
#influxdb默认密码
influxdbpasswd=123456

#neo4j默认密码，默认账户为neo4j
neo4jpasswd=troila@123
#neo4j前段web界面端口号
neo4jportf=7474
#neo4j后端端口号
neo4jportb=7687

#xxlport端口号
xxlport=8089

#rabbitmq控制台web端口号
rabbitmqportf=15672
#rabbitmq连接端口号
rabbitmqportb=5672
#rabbitmq新建host
rabbitmqhost=prod
#rabbitmq新建用户名
rabbitmqadmin=prod
#rabbitmq新建密码
rabbitmqpasswd=prod

#朗数后端镜像名
achillesib=172.24.103.101:8090/library/achilles-prod-back
#朗数前端镜像名
achillesif=172.24.103.101:8090/library/achilles-prod-front
#朗数后端版本
achillestb=34
#朗数前端版本
achillestf=40
#朗数分支
achillesb=prod
#朗数后端端口号
achillesportb=7280
#朗数前端端口号
achillesportf=7288

#朗图后端镜像名
athenaib=172.24.103.101:8090/library/athena-prod-back
#朗图前端镜像名
athenaif=172.24.103.101:8090/library/athena-prod-front
#朗图后端版本
athenatb=62
#朗图前端版本
athenatf=56
#朗图分支
athenab=prod
#朗图后端端口号
athenaportb=7080
#朗图前端端口号
athenaportf=7088

#朗擎前端端口号
hermesib=172.24.103.101:8090/library/hermes-prod-back
#朗擎前端镜像名
hermesif=172.24.103.101:8090/library/hermes-prod-front
#朗擎后端版本
hermestb=18
#朗擎前端版本
hermestf=15
#朗擎分支
hermesb=prod
#朗擎后端端口号
hermesportb=7180
#朗擎前端端口号
hermesportf=7188

function menu () {
        echo -e "\033[31m\033[1m
--------------------------------
|         1 初始化             |
|         2 docker19.03        |
|         3 python3.7          |
|         4 jdk1.8             |
|         5 mysql8             |
|         6 nginx1.16          |
|         7 fastdfs            |
|         8 redis              |
|         9 influxdb           |
|         10 neo4j             |
|         11 xxl-job           |
|         12 rabbitmq          |
|         13 朗数              |
|         14 朗图              |
|         15 朗擎              |
|         d 全部基础容器       |
|         p 全部产品容器       |
|         a 全部环境           |
|         q 退出               |
--------------------------------
\033[0m"
}

base () {
if [ ! -f "/usr/bin/dca" ] && [ ! -f "`dirname $0`/dca" ];then
	echo "没有找到命令启动脚本"
        read -p "是否继续进行安装?(y|n):" zp
                case "$zp" in
                  y|"")    
                        ;;
                  *)    
                        exit 999
                        ;;
                esac
fi
if [ ! -d "`dirname $0`/initool" ];then
	echo "请将initool目录放在脚本同级目录"
	read -p "是否继续进行安装?(y|n):" ub
		case "$ub" in
		  y|"")
			;;
		  *)
			exit 99
			;;			
		esac
fi
if [ ! -f "/usr/bin/dca" ] && [ -f "`dirname $0`/dca" ];then
	chmod 777 `dirname $0`/dca
	cp -r `dirname $0`/dca /usr/bin
fi
}

project () {
if [ ! -f "/usr/bin/dca" ] && [ ! -f "`dirname $0`/dca" ];then
	echo "没有找到命令启动脚本"
        read -p "是否继续进行安装?(y|n):" zp
                case "$zp" in
                  y|"")    
                        ;;
                  *)    
                        exit 999
                        ;;
                esac
fi
if [ ! -d "`dirname $0`/initpackage" ];then
	echo "请将initpackage目录放在脚本同级目录"
	read -p "是否继续进行安装?(y|n):" nb
		case "$nb" in
		  y|"")
			;;
		  *)
			exit 91
			;;			
		esac
fi
if [ ! -f "/usr/bin/dca" ] && [ -f "`dirname $0`/dca" ];then
	chmod 777 `dirname $0`/dca
	cp -r `dirname $0`/dca /usr/bin
fi
}

initf () {
read -p "是否继续初始化(y|n):" i
        case "$i" in
	  y|"")
		;;
          *)
                return 100
                ;;
        esac
#read -p "输入你想要使用的Linux的IP地址："  LAST
#hostnamectl  --static set-hostname  node-$END
#ETH=` ifconfig  | head -1 | awk -F ":"  '{print $1}'`
#GATE="`echo $LAST | awk -F "." '{print $1"."$2"."$3"."}'`2"
#END=`echo $LAST | awk -F "." '{print $NF}'`
echo "init ready"
sleep 5
cd `dirname $0`
setenforce 0
cat > /etc/selinux/config << EOF
SELINUX=disabled 
EOF

systemctl stop firewalld
systemctl disable  firewalld

#cat > /etc/sysconfig/network-scripts/ifcfg-$ETH <<EOF
#TYPE=Ethernet
#BOOTPROTO=none
#NAME=$ETH
#DEVICE=$ETH
#IPADDR="$LAST"
#GATEWAY=$GATE
#ONBOOT=yes
#DNS=8.8.8.8
#EOF

echo "nameserver 8.8.8.8" >>/etc/resolv.conf
systemctl restart network

mkdir /tmp/yum.repo.d
mv /etc/yum.repo.d/* /tmp/yum.repo.d
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
#yum -y install epel-release
#sed -i s/^#baseurl/baseurl/g /etc/yum.repos.d/epel.repo
#sed -i s/^metalink/#metalink/g /etc/yum.repos.d/epel.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum repolist

yum -y install ntpdate
timedatectl set-timezone 'Asia/Shanghai'
ntpdate cn.pool.ntp.org

yum -y install wget vim unzip zip lrzsz htop iftop
yum install -y yum-utils net-tools.x86_64 bash-completion

yum makecache fast
}

dockerf () {
docker --version &> /dev/null
if [ $? -eq 0 ];then
        read -p "本机可能已安装docker，请确认是否继续安装(y|n):" e
        case "$e" in
	  y|"")
		;;
          *)
                return 1
                ;;
        esac
fi
#docker and docker-compose
echo "docker building"
cd `dirname $0`
sleep 5
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum list docker-ce --showduplicates | sort -r
yum -y install docker-ce
#tar -xvf ./initool/docker-19.03.13.tgz
#cp -r ./docker/* /usr/bin/
#cat > /etc/systemd/system/docker.service << EOF
#[Unit]
#Description=Docker Application Container Engine
#Documentation=https://docs.docker.com
#After=network-online.target firewalld.service
#Wants=network-online.target
#
#[Service]
#Type=notify
#ExecStart=/usr/bin/dockerd
#ExecReload=/bin/kill -s HUP $MAINPID
#LimitNOFILE=infinity
#LimitNPROC=infinity
#TimeoutStartSec=0
#Delegate=yes
#KillMode=process
#Restart=on-failure
#StartLimitBurst=3
#StartLimitInterval=60s
#
#[Install]
#WantedBy=multi-user.target
#EOF
#chmod +x /etc/systemd/system/docker.service
echo "wait"
curl -L "https://get.daocloud.io/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
#cp -r ./initool/docker-compose /usr/local/bin
chmod +x /usr/local/bin/docker-compose

mkdir /etc/docker
cat > /etc/docker/daemon.json << EOF
{
  "insecure-registries":["172.24.103.101:8090","172.28.105.21:8090"],
  "registry-mirrors": ["https://ma8p1z36.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
systemctl start docker
systemctl enable docker
docker --version
docker-compose --version
}

pythonf () {
#python3.7
name=Python-3.7.0
path=/usr/local/python3
python3 --version &> /dev/null
if [ $? -eq 0 ];then
        read -p "本机可能已安装python3.7，请确认是否继续安装(y|n):" p
        case "$p" in
	  y|"")
		;;
          *)
                return 2
                ;;
        esac
fi
if [ -d "${path}" ];then
	echo "python相关目录已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			rm -rf ${path}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "python3.7 building"
sleep 5
cd `dirname $0`
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel gcc make epel-release

echo "wait"
#wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
tar -zxvf ./initool/${name}.tgz
cd ${name}
mkdir ${path}
./configure prefix=/usr/local/python3
make && make install
rm -rf ${name}

[ -f /usr/bin/python3 ] && mv /usr/bin/python3 /usr/bin/python3_old
[ -f /usr/bin/pip3 ] && mv /usr/bin/pip3  /usr/bin/pip3_old
ln -s /usr/local/python3/bin/python3.7 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3.7 /usr/bin/pip3

pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

python3 --version
}

jdkf () {
#java8
java -version &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已安装java，请确认是否继续安装(y|n):" e
	case "$e" in
	  y|"")
		;;
	  *)
		return 3
		;;
	esac
fi
if [ -d "/usr/local/jdk1.8.0_151" ];then
	echo "java相关目录已存在"
	read -p "是否卸载重装?(y|n):" po
		case "$po" in
		  y|"")
			rm -rf /usr/local/jdk1.8.0_151
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "java8 building"
sleep 5
cd `dirname $0`
  tar -zxvf ./initool/jdk-8u151-linux-x64.tar.gz -C /usr/local
      echo "export JAVA_HOME=/usr/local/jdk1.8.0_151" >>/etc/profile
      echo -e 'export PATH=$JAVA_HOME/bin:$PATH'>>/etc/profile
      echo -e 'export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar'>>/etc/profile
      source /etc/profile

java -version 
}

mysqlf () {
#mysql8
pathf=/home/mysql
pathd=/home/dc_mysql
name=mysql
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" my
	case "$my" in
	  y|"")
		;;
	  *)
	  	return 4
		;;
	esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
	echo "${name}相关目录${pathf}和${pathd}已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			docker-compose -f ${pathd}/docker-compose.yml down
			rm -rf ${pathf} ${pathd}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "${name}8 building"
sleep 5
cd `dirname $0`
docker load < ./initool/${name}.tar
mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  ${name}:
    image: ${name}:8
    container_name: mysqlf
    hostname: ${name}
    restart: always
    volumes:
      - "${pathf}/data:/var/lib/mysql"
      - "${pathf}/config/my.cnf:/etc/mysql/conf.d"
    ports:
      - "${mysqlport}:3306"
    environment:
      MYSQL_ROOT_PASSWORD: "${mysqlpasswd}"
    command: --default-authentication-plugin=mysql_native_password
EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
sleep 20
cp -r ./initool/{achilles,athena,hermes,xxl_job}.sql ${pathf}/config/my.cnf
docker exec -it mysqlf /bin/bash -c 'mysql -uroot -p'${mysqlpasswd}' < /etc/mysql/conf.d/achilles.sql'
sleep 5
docker exec -it mysqlf /bin/bash -c 'mysql -uroot -p'${mysqlpasswd}' < /etc/mysql/conf.d/athena.sql'
sleep 5
docker exec -it mysqlf /bin/bash -c 'mysql -uroot -p'${mysqlpasswd}' < /etc/mysql/conf.d/hermes.sql'
sleep 5
docker exec -it mysqlf /bin/bash -c 'mysql -uroot -p'${mysqlpasswd}' < /etc/mysql/conf.d/xxl_job.sql'
sleep 5
#docker exec -it mysql /bin/bash -c 'mysql -uroot -p'${mysqlpasswd}' -e "flush privileges;"'
docker ps -a | grep ${name}
}


nginxf () {
#nginx
pathf=/home/nginx
pathd=/home/dc_nginx
name=nginx
nginxpath=/home/html
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" ng
	case "$ng" in
	  y|"")
		;;
	  *)
	  	return 5
		;;
	esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
	echo "${name}相关目录${pathf}和${pathd}已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			docker-compose -f ${pathd}/docker-compose.yml down
			rm -rf ${pathf} ${pathd}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "${name} building"
sleep 5
cd `dirname $0`
docker load < ./initool/${name}.tar
mkdir ${pathf}
cat > ${pathf}/nginx.conf << EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 10240;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         $nginxpath;

        include /etc/nginx/default.d/*.conf;

        location / {
    #autoindex on;
    #autoindex_exact_size off;
    #autoindex_localtime on;
        }

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

}
EOF

mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  ${name}:
    image: ${name}:latest
    container_name: nginxf
    hostname: ${name}
    restart: always
    volumes:
      - "${pathf}/conf.d:/etc/nginx/conf.d"
      - "${pathf}/log:/var/log/nginx"
      - "${pathf}/html:$nginxpath"
      - "${pathf}/nginx.conf:/etc/nginx/nginx.conf"
    ports:
      - "${nginxport}:80"
EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
docker ps -a | grep ${name}
echo "需手动添加工作目录"
}


fastdfsf () {
#fastdfs
pathf=/home/fastdfs
pathd=/home/dc_fastdfs
name=fastdfs
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" fa
	case "$fa" in
	  y|"")
		;;
	  *)
	  	return 6
		;;
	esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
	echo "${name}相关目录${pathf}和${pathd}已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			docker-compose -f ${pathd}/docker-compose.yml down
			rm -rf ${pathf} ${pathd}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "${name} building"
sleep 5
cd `dirname $0`
docker load < ./initool/${name}.tar
mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  tracker:
    container_name: fastdfs-tracker
    image: delron/fastdfs:latest
    hostname: tracker
    restart: always
    volumes:
      - "${pathf}/tracker:/var/fdfs"
    network_mode: "host"
    command: "tracker"

  storage:
    container_name: fastdfs-storage
    image: delron/fastdfs:latest
    hostname: storage
    restart: always
    volumes:
      - "${pathf}/storage:/var/fdfs"
    environment:
      TRACKER_SERVER: "${ipf}:22122"
    network_mode: "host"
    command: "storage"
EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
docker ps -a | grep ${name}
}


redisf () {
#redis
pathf=/home/redis
pathd=/home/dc_redis
name=redis
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" re
	case "$re" in
	  y|"")
		;;
	  *)
	  	return 7
		;;
	esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
	echo "${name}相关目录${pathf}和${pathd}已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			docker-compose -f ${pathd}/docker-compose.yml down
			rm -rf ${pathf} ${pathd}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "${name} building"
sleep 5
cd `dirname $0`
docker load < ./initool/${name}.tar
mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  ${name}:
    image: ${name}:latest
    container_name: redisf
    hostname: ${name}
    restart: always
    volumes:
      - "${pathf}/redis:/data/redis"
      - "${pathf}/conf/redis.conf:/etc/redis/redis.conf"
    ports:
      - "${redisport}:6379"
    command: "redis-server /etc/redis/redis.conf --requirepass $redispasswd --appendonly yes"
EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
docker ps -a | grep ${name}
}



influxdbf () {
#influxdb
pathf=/home/influxdb
pathd=/home/dc_influxdb
name=influxdb
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" inf
	case "$inf" in
	  y|"")
		;;
	  *)
	  	return 7
		;;
	esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
	echo "${name}相关目录${pathf}和${pathd}已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			docker-compose -f ${pathd}/docker-compose.yml down
			rm -rf ${pathf} ${pathd}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "${name} building"
sleep 5
cd `dirname $0`
docker load < ./initool/${name}.tar
mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  ${name}:
    image: ${name}:latest
    container_name: influxdbf
    hostname: ${name}
    restart: always
    environment:
      INFLUXDB_DB: "${influxdbdb}"
      INFLUXDB_ADMIN_USER: "${influxdbadmin}"
      INFLUXDB_ADMIN_PASSWORD: "${influxdbpasswd}"
    ports:
      - "${influxdbport}:8086"
    volumes:
      - "${pathf}:/var/lib/influxdb"
EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
docker ps -a | grep ${name}
#echo "
#未设置用户名密码，如有需要可按照如下步骤
#进入容器
#influx
#show users;
#create user 'root' with password 'yourpasswd'
#influx -username 'root' -password 'yourpasswd'
#drop user root
#create user "root" with password 'newpwd' with all privileges
#show users
#
#user admin
#---- -----
#root true
#
#vim /etc/influxdb/influxdb.conf
#auth-enabled = true
#"
}

neo4jf () {
#neo4j
pathf=/home/neo4j
pathd=/home/dc_neo4j
name=neo4j
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" neo
	case "$neo" in
	  y|"")
		;;
	  *)
	  	return 8
		;;
	esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
	echo "${name}相关目录${pathf}和${pathd}已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			docker-compose -f ${pathd}/docker-compose.yml down
			rm -rf ${pathf} ${pathd}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "${name} building"
sleep 5
cd `dirname $0`
docker load < ./initool/${name}.tar
mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  ${name}:
    image: ${name}:latest
    container_name: neo4jf
    hostname: ${name}
    restart: always
    volumes:
      - "${pathf}/conf:/var/lib/neo4j/conf"
      - "${pathf}/import:/var/lib/neo4j/import"
      - "${pathf}/logs:/logs"
      - "${pathf}/data:/data"
    ports:
      - "${neo4jportf}:7474"
      - "${neo4jportb}:7687"
    environment:
      - "NEO4J_AUTH=neo4j/$neo4jpasswd"
EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
cat > ${pathf}/conf/neo4j.conf << EOF
dbms.default_listen_address=0.0.0.0
dbms.memory.pagecache.size=512M

dbms.connectors.default_listen_address=0.0.0.0

dbms.connector.bolt.listen_address=0.0.0.0:7687

dbms.connector.http.listen_address=0.0.0.0:7474
dbms.tx_log.rotation.retention_policy=100M size
dbms.directories.logs=/logs
EOF
docker-compose -f ${pathd}/docker-compose.yml restart ${name}
docker ps -a | grep ${name}
}

xxlf () {
#xxl-job
pathf=/home/xxl-job
pathd=/home/dc_xxl-job
name=xxl-job
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" xx
	case "$xx" in
	  y|"")
		;;
	  *)
	  	return 9
		;;
	esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
	echo "${name}相关目录${pathf}和${pathd}已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			docker-compose -f ${pathd}/docker-compose.yml down
			rm -rf ${pathf} ${pathd}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "${name} building"
sleep 5
cd `dirname $0`
docker load < ./initool/${name}.tar
mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  ${name}:
    image: ${name}:latest
    container_name: xxl-jobf
    hostname: ${name}
    restart: always
    volumes:
      - "${pathf}/logs:/opt/logs"
      #- "${pathf}/app:/usr/src/app"
    ports:
      - "${xxlport}:8089"
    environment:
      - "JAVA_OPTS=-Xms1024m -Xmx1024m"
      - "SPRING_PROFILES_ACTIVE=prod"
EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
docker ps -a | grep ${name}
}

rabbitmqf () {
#rabbitmq
pathf=/home/rabbitmq
pathd=/home/dc_rabbitmq
name=rabbitmq
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" rab
	case "$rab" in
	  y|"")
		;;
	  *)
	  	return 10
		;;
	esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
	echo "${name}相关目录${pathf}和${pathd}已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			docker-compose -f ${pathd}/docker-compose.yml down
			rm -rf ${pathf} ${pathd}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "${name} building"
sleep 5
cd `dirname $0`
docker load < ./initool/${name}.tar
mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  ${name}:
    image: ${name}:management
    hostname: ${name}
    container_name: rabbitmqf
    restart: always
    volumes:
      - "${pathf}/data:/var/lib/rabbitmq"
    ports:
      - "${rabbitmqportf}:15672"
      - "${rabbitmqportb}:5672"
#    command:
#      - /bin/sh
#      - -c
#      - |
#        rabbitmqctl add_vhost prod
#        rabbitmqctl add_user prod prod
#        rabbitmqctl set_user_tags prod administrator
#        rabbitmqctl set_permissions -p prod prod ".*" ".*" ".*"
EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
docker exec -it rabbitmqf /bin/bash -c 'rabbitmqctl add_vhost ${rabbitmqhost} && rabbitmqctl add_user ${rabbitmqadmin} ${rabbitmqpasswd} && rabbitmqctl set_user_tags ${rabbitmqadmin} administrator && rabbitmqctl set_permissions -p ${rabbitmqhost} ${rabbitmqadmin} ".*" ".*" ".*"'
docker ps -a | grep ${name}
}

achillesf () {
#朗数
pathf=/home/achilles
pathd=/home/dc_achilles
name=achilles
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" rab
	case "$rab" in
	  y|"")
		;;
	  *)
	  	return 10
		;;
	esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
	echo "${name}相关目录${pathf}和${pathd}已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			docker-compose -f ${pathd}/docker-compose.yml down
			rm -rf ${pathf} ${pathd}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "${name} building"
sleep 5
cd `dirname $0`
docker load < ./initpackage/${name}-${achillesb}-back.tar
docker load < ./initpackage/${name}-${achillesb}-front.tar
mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  ${name}-${achillesb}-back:
    image: ${achillesib}:${achillestb}
    container_name: ${name}-${achillesb}-back-1.0.0
    restart: always
    volumes:
      - "${pathf}/logs:/usr/src/app/logs"
#      - "${pathf}/app:/usr/src/app"
    ports:
      - "${achillesportb}:7085"
      - "9999:9999"
    environment:
      - "JAVA_OPTS=-Xms2048m -Xmx2048m"
      - "SPRING_PROFILES_ACTIVE=${achillesb}"

  ${name}-${achillesb}-front:
    image: ${achillesif}:${achillestf}
    container_name: ${name}-${achillesb}-front-1.0.0
    restart: always
    ports:
      - "${achillesportf}:80"
#    volumes:
#      - "${pathf}/html:/usr/share/nginx/html"

EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
docker ps -a | grep ${name}
}

athenaf () {
#朗图
pathf=/home/athena
pathd=/home/dc_athena
name=athena
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
	read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" rab
	case "$rab" in
	  y|"")
		;;
	  *)
	  	return 10
		;;
	esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
	echo "${name}相关目录${pathf}和${pathd}已存在"
	read -p "是否卸载重装?(y|n):" pl
		case "$pl" in
		  y|"")
			docker-compose -f ${pathd}/docker-compose.yml down
			rm -rf ${pathf} ${pathd}
			;;
		  *)
			return 99
			;;			
		esac
fi
echo "${name} building"
sleep 5
cd `dirname $0`
docker load < ./initpackage/${name}-${athenab}-back.tar
docker load < ./initpackage/${name}-${athenab}-front.tar
mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  ${name}-${athenab}-back:
    image: ${athenaib}:${athenatb}
    container_name: ${name}-${athenai}-back-1.0.0
    restart: always
    volumes:
      - "${pathf}/logs:/usr/src/app/logs"
#      - "${pathf}/app:/usr/src/app"
    ports:
      - "${athenaportb}:7080"
    environment:
      - "JAVA_OPTS=-Xms2048m -Xmx2048m"
      - "SPRING_PROFILES_ACTIVE=${athenab}"

  ${name}-${athenab}-front:
    image: ${athenaif}:${athenatf}
    container_name: ${name}-${athenab}-front-1.0.0
    restart: always
    ports:
      - "${athenaportf}:80"
#    volumes:
#      - "${pathf}/html:/usr/share/nginx/html"

EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
docker ps -a | grep ${name}
}

hermesf () {
#朗图
pathf=/home/hermes
pathd=/home/dc_hermes
name=hermes
systemctl start docker
docker ps -a | grep ${name} &> /dev/null
if [ $? -eq 0 ];then
        read -p "本机可能已经安装${name}镜像，请确认是否继续安装(y|n):" rab
        case "$rab" in
          y|"")
                ;;
          *)
                return 10
                ;;
        esac
fi
if [ -d "${pathf}" ] || [ -d "${pathd}" ];then
        echo "${name}相关目录${pathf}和${pathd}已存在"
        read -p "是否卸载重装?(y|n):" pl
                case "$pl" in
                  y|"")
                        docker-compose -f ${pathd}/docker-compose.yml down
                        rm -rf ${pathf} ${pathd}
                        ;;
                  *)
                        return 99
                        ;;
                esac
fi
echo "${name} building"
sleep 5
cd `dirname $0`
docker load < ./initpackage/${name}-${hermesb}-back.tar
docker load < ./initpackage/${name}-${hermesb}-front.tar
mkdir ${pathd}
cat > ${pathd}/docker-compose.yml <<EOF
version: '3.7'
services:
  ${name}-${hermesb}-back:
    image: ${hermesib}:${hermestb}
    container_name: ${name}-${hermesi}-back-1.0.0
    restart: always
    volumes:
      - "${pathf}/logs:/usr/src/app/logs"
#      - "${pathf}/app:/usr/src/app"
    ports:
      - "${hermesportb}:7180"
      - "7183:7183"
    environment:
      - "JAVA_OPTS=-Xms1024m -Xmx1024m"
      - "SPRING_PROFILES_ACTIVE=${hermesb}"

  ${name}-${hermesb}-front:
    image: ${hermesif}:${hermestf}
    container_name: ${name}-${hermesb}-front-1.0.0
    restart: always
    ports:
      - "${hermesportf}:80"
#    volumes:
#      - "${pathf}/html:/usr/share/nginx/html"

EOF
docker-compose -f ${pathd}/docker-compose.yml up -d
docker ps -a | grep ${name}
}

pick () {
while true
do
read -p "choose your operation:" n
case "$n" in
  1)
        initf
	exit 1
        ;;
  2)
        dockerf
	exit 2
        ;;
  3)
	base
        pythonf
	exit 3
        ;;
  4)
	base
        jdkf
	exit 4
        ;;
  5)
	base
	mysqlf
	exit 5
	;;
  6)
	base
	nginxf
	exit 6
	;;
  7)
	base
	fastdfsf
	exit 7
	;;
  8)
	base
	redisf
	exit 8
	;;
  9)
	base
	influxdbf
	exit 9
	;;
  10)
	base
	neo4jf
	exit 10
	;;
  11)
	base
	xxlf
	exit 11
	;;
  12)
	base
	rabbitmqf
	exit 12
	;;
  13)
	project
	achillesf
	exit 13
	;;
  14)
	project
	athenaf
	exit 14
	;;
  15)
	project
	hermesf
	exit 15
	;;
  a)
	base
	project
	initf
	dockerf 
	pythonf 
	jdkf
	mysqlf
	nginxf
	fastdfsf
	redisf
	influxdbf
	neo4jf
	xxlf
	rabbitmqf
	achillesf
	athenaf
	hermesf
	exit 0
	;;
  d)
	base
        dockerf
	mysqlf
	nginxf
	fastdfsf
	redisf
	influxdbf
	neo4jf
	xxlf
	rabbitmqf
	exit 100
	;;
  p)
	project
	achillesf
	athenaf
	hermesf
	exit 97
	;;
  q)
	echo "ctrl+c不比这个简单？"
        exit 
        ;;
  *)
	echo "别闹，认真选"
	;;
esac
done
}

menu
pick

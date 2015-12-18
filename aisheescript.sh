#!/bin/bash
#######################################################################################################
#                                      Aishee Script v1.2                                             #
#            yum -y install wget && wget http://aisheeblog/scripts/install && bash install            #
#######################################################################################################

if [ $(id -u) != "0" ]; then
    printf "You can login root user!\n"
    exit
fi

if [ -f /etc/aisheescript/scripts.conf ]; then
echo "AisheeScript is installed in Server, please check...."
exit
fi

#Tham so
aisheescript_ver="1.1"
pma_version="4.4.15.1"
script_url="http://aisheeblog.com/scripts"

yum -y install gawk bc
wget -q $script_url/package/calc -O /bin/calc && chmod +x /bin/calc

clear
printf "=========================================================================\n"
printf "Check parameter of VPS/Server before install script \n"
printf "=========================================================================\n"

cpuname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cpucores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
cpufreq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
svram=$( free -m | awk 'NR==2 {print $2}' )
svhdd=$( df -h | awk 'NR==2 {print $2}' )
svswap=$( free -m | awk 'NR==4 {print $2}' )
svip=$(curl -s https://api.ipify.org)


printf "=========================================================================\n"
printf "Parameter of Server \n"
printf "=========================================================================\n"
echo "CPU Type : $cpuname"
echo "CPU core : $cpucores"
echo "Core Speed : $cpufreq MHz"
echo "Ram total : $svram MB"
echo "Swap total : $svswap MB"
echo "Disk total : $svhdd GB"
echo "IP Server : $svip"
printf "=========================================================================\n"
printf "=========================================================================\n"
sleep 3


clear
printf "=========================================================================\n"
printf "Proccesing setup script... \n"
printf "=========================================================================\n"

printf "Select version PHP:\n"
prompt="Enter the number [1-3]: "
options=("PHP 5.6" "PHP 5.5" "PHP 5.4")
PS3="$prompt"
select opt in "${options[@]}"; do

    case "$REPLY" in
    1) php_version="5.6"; break;;
    2) php_version="5.5"; break;;
    3) php_version="5.4"; break;;
    $(( ${#options[@]}+1 )) ) printf "\nGood bye....!\n"; break;;
    *) echo "Select not correct, please try again...";continue;;
    esac

done

printf "\nEnter the main domain [ENTER]: "
read svdomain
if [ "$svdomain" = "" ]; then
	svdomain="aishee.net"
echo "Failed, please try again enter the domain!"
fi

printf "\nEnter the port phpMyAdmin [ENTER]: "
read svport
if [ "$svport" = "" ] || [ "$svport" = "80" ] || [ "$svport" = "443" ] || [ "$svport" = "22" ] || [ "$svport" = "3306" ] || [ "$svport" = "25" ] || [ "$svport" = "465" ] || [ "$svport" = "587" ]; then
	svport="2424"
echo "Port phpMyAdmin can not using port process system, please try again!"
echo "Default port is 2424"
echo
fi

printf "=========================================================================\n"
printf "Complete the process of preparing... \n"
printf "=========================================================================\n"


rm -f /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

if [ -s /etc/selinux/config ]; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

#Install EPEL + Remi Repo
yum -y install epel-release
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

#Install Nginx Repo
rpm -Uvh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm

#Install MariaDB Repo
wget -O /etc/yum.repos.d/MariaDB.repo http://hocvps.com/scripts/repo/mariadb/centos/$(rpm -E %centos)/$(uname -i)/5

service xinetd stop
chkconfig xinetd off
service saslauthd stop
chkconfig saslauthd off

yum -y remove mysql* php* httpd* sendmail* postfix* rsyslog*
yum -y update

clear
printf "=========================================================================\n"
printf "Preparing complete... \n"
printf "=========================================================================\n"
sleep 3

if [ "$php_version" = "5.6" ]; then
cat > "/etc/yum.repos.d/remi.repo" <<END
# Repository: http://rpms.remirepo.net/
# Blog:       http://blog.remirepo.net/
# Forum:      http://forum.remirepo.net/

[remi]
name=Remi's RPM repository for Enterprise Linux 6 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/6/remi/$basearch/
mirrorlist=http://rpms.remirepo.net/enterprise/6/remi/mirror
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-php55]
name=Remi's PHP 5.5 RPM repository for Enterprise Linux 6 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/6/php55/$basearch/
mirrorlist=http://rpms.remirepo.net/enterprise/6/php55/mirror
# WARNING: If you enable this repository, you must also enable "remi"
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-php56]
name=Remi's PHP 5.6 RPM repository for Enterprise Linux 6 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/6/php56/$basearch/
mirrorlist=http://rpms.remirepo.net/enterprise/6/php56/mirror
# WARNING: If you enable this repository, you must also enable "remi"
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
END
	yum -y install nginx php-fpm php-common php-gd php-mysql php-pdo php-xml php-mbstring php-mcrypt php-curl php-opcache
elif [ "$php_version" = "5.5" ]; then

cat > "/etc/yum.repos.d/remi.repo" <<END
# Repository: http://rpms.remirepo.net/
# Blog:       http://blog.remirepo.net/
# Forum:      http://forum.remirepo.net/

[remi]
name=Remi's RPM repository for Enterprise Linux 6 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/6/remi/$basearch/
mirrorlist=http://rpms.remirepo.net/enterprise/6/remi/mirror
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-php55]
name=Remi's PHP 5.5 RPM repository for Enterprise Linux 6 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/6/php55/$basearch/
mirrorlist=http://rpms.remirepo.net/enterprise/6/php55/mirror
# WARNING: If you enable this repository, you must also enable "remi"
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-php56]
name=Remi's PHP 5.6 RPM repository for Enterprise Linux 6 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/6/php56/$basearch/
mirrorlist=http://rpms.remirepo.net/enterprise/6/php56/mirror
# WARNING: If you enable this repository, you must also enable "remi"
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
END
	yum -y install nginx php-fpm php-common php-gd php-mysql php-pdo php-xml php-mbstring php-mcrypt php-curl php-opcache
else
#Enable Remi Repo
cat > "/etc/yum.repos.d/remi.repo" <<END
# Repository: http://rpms.remirepo.net/
# Blog:       http://blog.remirepo.net/
# Forum:      http://forum.remirepo.net/

[remi]
name=Remi's RPM repository for Enterprise Linux 6 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/6/remi/$basearch/
mirrorlist=http://rpms.remirepo.net/enterprise/6/remi/mirror
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-php55]
name=Remi's PHP 5.5 RPM repository for Enterprise Linux 6 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/6/php55/$basearch/
mirrorlist=http://rpms.remirepo.net/enterprise/6/php55/mirror
# WARNING: If you enable this repository, you must also enable "remi"
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-php56]
name=Remi's PHP 5.6 RPM repository for Enterprise Linux 6 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/6/php56/$basearch/
mirrorlist=http://rpms.remirepo.net/enterprise/6/php56/mirror
# WARNING: If you enable this repository, you must also enable "remi"
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
END
	yum -y install nginx php-fpm php-common php-gd php-mysql php-pdo php-xml php-mbstring php-mcrypt php-curl php-devel gcc
fi

#Install MariaDB
yum -y install MariaDB-server MariaDB-client

yum -y install exim syslog-ng syslog-ng-libdbi cronie unzip zip nano

clear
printf "=========================================================================\n"
printf "Cai dat xong, bat dau cau hinh... \n"
printf "=========================================================================\n"
sleep 3


ramformariadb=$(calc $svram/10*6)
ramforphpnginx=$(calc $svram-$ramformariadb)
max_children=$(calc $ramforphpnginx/30)
memory_limit=$(calc $ramforphpnginx/5*3)M
buff_size=$(calc $ramformariadb/10*8)M
log_size=$(calc $ramformariadb/10*2)M

#Configure Autostart
chkconfig --add nginx
chkconfig --levels 235 nginx on
chkconfig --add php-fpm
chkconfig --levels 235 php-fpm on
chkconfig --add exim
chkconfig --levels 235 exim on
chkconfig --add syslog-ng
chkconfig --levels 235 syslog-ng on

service mysql start
service exim start
service syslog-ng start

mkdir -p /home/$svdomain/public_html
mkdir /home/$svdomain/private_html
mkdir /home/$svdomain/logs
chmod 777 /home/$svdomain/logs


mkdir -p /var/log/nginx
chown -R nginx:nginx /var/log/nginx
chown -R nginx:nginx /var/lib/php/session

wget -q $script_url/html/index.html -O /home/$svdomain/public_html/index.html

#Add Zend Opcache
opcache_path='opcache.so' #Default for PHP 5.5 and PHP 5.6

if [ "$php_version" = "5.4" ]; then
	cd /usr/local/src
	wget http://pecl.php.net/get/ZendOpcache
	tar xvfz ZendOpcache
	cd zendopcache-7.*
	phpize
	php_config_path=`which php-config`
	./configure --with-php-config=$php_config_path
	make
	make install
	rm -rf /usr/local/src/zendopcache*
	rm -f ZendOpcache
	opcache_path=`find / -name 'opcache.so'`
fi

#Linfo
mkdir /home/$svdomain/private_html/vpsinfo/
cd /home/$svdomain/private_html/vpsinfo/
wget -q https://github.com/jrgp/linfo/archive/master.zip
unzip -q master.zip
mv -f linfo-master/* .
mv sample.config.inc.php config.inc.php
rm -rf linfo-master master.zip

cat > "/etc/nginx/nginx.conf" <<END

user  nginx;
worker_processes  $cpucores;
worker_rlimit_nofile 65536;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
	worker_connections  2048;
}


http {
	include       /etc/nginx/mime.types;
	default_type  application/octet-stream;

	log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
	              '\$status \$body_bytes_sent "\$http_referer" '
	              '"\$http_user_agent" "\$http_x_forwarded_for"';

	#Nginx Security Headers
	add_header X-Frame-Options SAMEORIGIN;
	add_header X-XSS-Protection "1; mode=block";
	add_header X-Content-Type-Options nosniff;

	access_log  off;
	sendfile on;
	tcp_nopush on;
	tcp_nodelay off;
	types_hash_max_size 2048;
	server_tokens off;
	server_names_hash_bucket_size 128;
	client_max_body_size 20m;
	client_body_buffer_size 256k;
	client_body_in_file_only off;
	client_body_timeout 60s;
	client_header_buffer_size 256k;
	client_header_timeout  20s;
	large_client_header_buffers 8 256k;
	keepalive_timeout 10;
	keepalive_disable msie6;
	reset_timedout_connection on;
	send_timeout 60s;

	gzip on;
	gzip_static on;
	gzip_disable "msie6";
	gzip_vary on;
	gzip_proxied any;
	gzip_comp_level 6;
	gzip_buffers 16 8k;
	gzip_http_version 1.1;
	gzip_types text/plain text/css application/json text/javascript application/javascript text/xml application/xml application/xml+rss;

	include /etc/nginx/conf.d/*.conf;
}
END

rm -rf /etc/nginx/conf.d/*

svdomain_redirect="www.$svdomain"
if [[ $svdomain == *www* ]]; then
    svdomain_redirect=${svdomain/www./''}
fi

cat > "/usr/share/nginx/html/403.html" <<END
<html>
<head><title>403 Forbidden</title></head>
<body bgcolor="white">
<center><h1>403 Forbidden</h1></center>
<hr><center>aisheescript-nginx</center>
</body>
</html>
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
END

cat > "/usr/share/nginx/html/404.html" <<END
<html>
<head><title>404 Not Found</title></head>
<body bgcolor="white">
<center><h1>404 Not Found</h1></center>
<hr><center>hocvps-nginx</center>
</body>
</html>
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
END

cat > "/etc/nginx/conf.d/$svdomain.conf" <<END
server {
	server_name $svdomain_redirect;
	rewrite ^(.*) http://$svdomain\$1 permanent;
    	}
server {
	listen   80 default_server;

	access_log off;
	# access_log /home/$svdomain/logs/access.log;
	error_log off;
    	# error_log /home/$svdomain/logs/error.log;
    	root /home/$svdomain/public_html;
	index index.php index.html index.htm;
    	server_name $svdomain;

    	location / {
		try_files \$uri \$uri/ /index.php?\$args;
	}

    	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
        	include /etc/nginx/fastcgi_params;
        	fastcgi_pass 127.0.0.1:9000;
        	fastcgi_index index.php;
		fastcgi_connect_timeout 300;
		fastcgi_send_timeout 300;
		fastcgi_read_timeout 300;
		fastcgi_buffer_size 32k;
		fastcgi_buffers 8 16k;
		fastcgi_busy_buffers_size 32k;
		fastcgi_temp_file_write_size 32k;
		fastcgi_intercept_errors on;
        	fastcgi_param SCRIPT_FILENAME /home/$svdomain/public_html\$fastcgi_script_name;
    	}
	location /nginx_status {
  		stub_status on;
  		access_log   off;
	}
	location /php_status {
		fastcgi_pass 127.0.0.1:9000;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME  /home/$svdomain/public_html\$fastcgi_script_name;
		include /etc/nginx/fastcgi_params;
    	}
	location ~ /\. {
		deny all;
	}
        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }
       location = /robots.txt {
              allow all;
              log_not_found off;
              access_log off;
       }
	location ~* \.(3gp|gif|jpg|jpeg|png|ico|wmv|avi|asf|asx|mpg|mpeg|mp4|pls|mp3|mid|wav|swf|flv|exe|zip|tar|rar|gz|tgz|bz2|uha|7z|doc|docx|xls|xlsx|pdf|iso|eot|svg|ttf|woff)$ {
	        gzip_static off;
		add_header Pragma public;
		add_header Cache-Control "public, must-revalidate, proxy-revalidate";
		access_log off;
		expires 30d;
		break;
        }

        location ~* \.(txt|js|css)$ {
	        add_header Pragma public;
		add_header Cache-Control "public, must-revalidate, proxy-revalidate";
		access_log off;
		expires 30d;
		break;
        }
    }

server {
	listen   $svport;
 	access_log        off;
	log_not_found     off;
 	error_log         off;
    	root /home/$svdomain/private_html;
	index index.php index.html index.htm;
    	server_name $svdomain;

     	location / {
		try_files \$uri \$uri/ /index.php;
	}
    	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
        	include /etc/nginx/fastcgi_params;
        	fastcgi_pass 127.0.0.1:9000;
        	fastcgi_index index.php;
		fastcgi_connect_timeout 300;
		fastcgi_send_timeout 300;
		fastcgi_read_timeout 300;
		fastcgi_buffer_size 32k;
		fastcgi_buffers 8 16k;
		fastcgi_busy_buffers_size 32k;
		fastcgi_temp_file_write_size 32k;
		fastcgi_intercept_errors on;
        	fastcgi_param SCRIPT_FILENAME /home/$svdomain/private_html\$fastcgi_script_name;
    	}
        location ~* \.(bak|back|bk)$ {
		deny all;
	}
}
END

cat > "/etc/php-fpm.d/www.conf" <<END
[www]
listen = 127.0.0.1:9000
listen.allowed_clients = 127.0.0.1
user = nginx
group = nginx
pm = dynamic
pm.max_children = $max_children
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 6
pm.max_requests = 500
pm.status_path = /php_status
request_terminate_timeout = 120s
request_slowlog_timeout = 4s
slowlog = /home/$svdomain/banned/logs/php-fpm-slow.log
rlimit_files = 131072
rlimit_core = unlimited
catch_workers_output = yes
env[HOSTNAME] = \$HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
php_admin_value[error_log] = /home/$svdomain/banned/logs/php-fpm-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path] = /var/lib/php/session
END

cat > "/etc/php.ini" <<END
[PHP]
engine = On
short_open_tag = Off
asp_tags = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = 17
disable_functions = escapeshellarg,escapeshellcmd,exec,ini_alter,parse_ini_file,passthru,pcntl_exec,popen,proc_close,proc_get_status,proc_nice,proc_open,proc_terminate,show_source,shell_exec,symlink,system
disable_classes =
zend.enable_gc = On
expose_php = Off
max_execution_time = 30
max_input_time = 65
memory_limit = $memory_limit
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = On
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
track_errors = Off
html_errors = On
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
post_max_size = 210M
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
doc_root =
user_dir =
enable_dl = Off
cgi.fix_pathinfo=0
file_uploads = On
upload_max_filesize = 230M
max_file_uploads = 20
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
cli_server.color = On

[Date]
date.timezone = Asia/Bangkok

[filter]

[iconv]

[intl]

[sqlite]

[sqlite3]

[Pcre]

[Pdo]

[Pdo_mysql]
pdo_mysql.cache_size = 2000
pdo_mysql.default_socket=

[Phar]

[mail function]
SMTP = localhost
smtp_port = 25
sendmail_path = /usr/sbin/sendmail -t -i
mail.add_x_header = On

[SQL]
sql.safe_mode = Off

[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1

[Interbase]
ibase.allow_persistent = 1
ibase.max_persistent = -1
ibase.max_links = -1
ibase.timestampformat = "%Y-%m-%d %H:%M:%S"
ibase.dateformat = "%Y-%m-%d"
ibase.timeformat = "%H:%M:%S"

[MySQL]
mysql.allow_local_infile = On
mysql.allow_persistent = On
mysql.cache_size = 2000
mysql.max_persistent = -1
mysql.max_links = -1
mysql.default_port =
mysql.default_socket =
mysql.default_host =
mysql.default_user =
mysql.default_password =
mysql.connect_timeout = 60
mysql.trace_mode = Off

[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.cache_size = 2000
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off

[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off

[OCI8]

[PostgreSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0

[Sybase-CT]
sybct.allow_persistent = On
sybct.max_persistent = -1
sybct.max_links = -1
sybct.min_server_severity = 10
sybct.min_client_severity = 10

[bcmath]
bcmath.scale = 0

[browscap]

[Session]
session.save_handler = files
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly =
session.serialize_handler = php
session.gc_probability = 1
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.bug_compat_42 = Off
session.bug_compat_warn = Off
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.hash_function = 0
session.hash_bits_per_character = 5
url_rewriter.tags = "a=href,area=href,frame=src,input=src,form=fakeentry"

[MSSQL]
mssql.allow_persistent = On
mssql.max_persistent = -1
mssql.max_links = -1
mssql.min_error_severity = 10
mssql.min_message_severity = 10
mssql.compatability_mode = Off

[Assertion]

[mbstring]

[gd]

[exif]

[Tidy]
tidy.clean_output = Off

[soap]
soap.wsdl_cache_enabled=1
soap.wsdl_cache_dir="/tmp"
soap.wsdl_cache_ttl=86400
soap.wsdl_cache_limit = 5

[sysvshm]

[ldap]
ldap.max_links = -1

[mcrypt]

[dba]

END

cat > "/etc/php-fpm.conf" <<END
include=/etc/php-fpm.d/*.conf

[global]
pid = /var/run/php-fpm/php-fpm.pid
error_log = /home/$svdomain/banned/logs/php-fpm.log
emergency_restart_threshold = 10
emergency_restart_interval = 60s
process_control_timeout = 10s
daemonize = yes
END

cat > "/etc/my.cnf.d/server.cnf" <<END
[server]

[mysqld]
skip-host-cache
skip-name-resolve
collation-server = utf8_unicode_ci
init-connect='SET NAMES utf8'
character-set-server = utf8
skip-character-set-client-handshake

user = mysql
default_storage_engine = InnoDB
socket = /var/lib/mysql/mysql.sock
pid_file = /var/lib/mysql/mysql.pid

key_buffer_size = 32M
myisam_recover = FORCE,BACKUP
max_allowed_packet = 16M
max_connect_errors = 1000000
datadir = /var/lib/mysql/
tmp_table_size = 32M
max_heap_table_size = 32M
query_cache_type = ON
query_cache_size = 2M
long_query_time = 5
max_connections = 50
wait_timeout = 30
thread_cache_size = 50
open_files_limit = 65536
table_definition_cache = 1024
table_open_cache = 1024
innodb_flush_method = O_DIRECT
innodb_log_files_in_group = 2
innodb_log_file_size = $log_size
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = 1
innodb_buffer_pool_size = $buff_size

log_error = /home/$svdomain/banned/logs/mysql.log
log_queries_not_using_indexes = 0
slow_query_log = 1
slow_query_log_file = /home/$svdomain/banned/logs/mysql-slow.log

[embedded]

[mysqld-5.5]

[mariadb]

[mariadb-5.5]
END


cat >> "/etc/security/limits.conf" <<END
* soft nofile 65536
* hard nofile 65536
nginx soft nofile 65536
nginx hard nofile 65536
END

ulimit  -n 65536

#Zend Opcache setup
wget -q https://raw.github.com/amnuts/opcache-gui/master/index.php -O /home/$svdomain/private_html/op.php
cat > /etc/php.d/*opcache*.ini <<END
zend_extension=$opcache_path
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=4000
opcache.max_wasted_percentage=5
opcache.use_cwd=1
opcache.validate_timestamps=1
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.blacklist_filename=/etc/php.d/opcache-default.blacklist
END

cat > /etc/php.d/opcache-default.blacklist <<END
/home/*/public_html/wp-content/plugins/backwpup/*
/home/*/public_html/wp-content/plugins/duplicator/*
/home/*/public_html/wp-content/plugins/updraftplus/*
END

mkdir -p /etc/aisheescript/menu
mkdir -p /etc/aisheescript/update

cat > "/etc/aisheescript/scripts.conf" <<END
mainsite="$svdomain"
priport="$svport"
serverip="$svip"
aisheescript_ver="$aisheescript_ver"
script_url="$script_url"
END

rm -f /var/lib/mysql/ib_logfile0
rm -f /var/lib/mysql/ib_logfile1
rm -f /var/lib/mysql/ibdata1

service mysql start

clear
printf "=========================================================================\n"
printf "Starting configure MariaDB ... \n"
printf "=========================================================================\n"
#Create password mysql root
root_password=`date |md5sum |cut -c '17-31'`
'/usr/bin/mysqladmin' -u root password "$root_password"
mysql -u root -p"$root_password" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost')"
mysql -u root -p"$root_password" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$root_password" -e "DROP DATABASE test"
mysql -u root -p"$root_password" -e "FLUSH PRIVILEGES"

cat >> "/etc/aisheescript/scripts.conf" <<END
mariadbpass="$root_password"
END
service mysql restart

clear
printf "=========================================================================\n"
printf "Complete configuration... \n"
printf "=========================================================================\n"
cd /home/$svdomain/private_html/
wget -q https://files.phpmyadmin.net/phpMyAdmin/$pma_version/phpMyAdmin-$pma_version-english.zip
unzip -q phpMyAdmin-$pma_version-english.zip
mv -f phpMyAdmin-$pma_version-english/* .
rm -rf phpMyAdmin-$pma_version-english

#Change port ssh
sed -i 's/#Port 22/Port 3108/g' /etc/ssh/sshd_config

if [ -f /etc/sysconfig/iptables ]; then
service iptables start
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 25 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -p tcp --dport 465 -j ACCEPT
iptables -I INPUT -p tcp --dport 587 -j ACCEPT
iptables -I INPUT -p tcp --dport $svport -j ACCEPT
iptables -I INPUT -p tcp --dport 2222 -j ACCEPT
service iptables save
fi

mkdir -p /var/lib/php/session
chown -R nginx:nginx /var/lib/php
chown -R nginx:nginx /home/*/public_html
chown -R nginx:nginx /home/*/private_html

rm -f /root/install*
echo -n "cd /home" >> /root/.bashrc

clear
printf "=========================================================================\n"
printf "Configuration successfuly, starting add menu aisheescript,please waiting \n"
printf "=========================================================================\n"

wget -q $script_url/aisheesvps -O /bin/aisheesvps && chmod +x /bin/aisheesvps
wget -q $script_url/component/phpmyadmin-off -O /etc/aisheescript/menu/phpmyadmin-off && chmod +x /etc/aisheescript/menu/phpmyadmin-off
wget -q $script_url/component/backup-code -O /etc/aisheescript/menu/backup-code && chmod +x /etc/aisheescript/menu/backup-code
wget -q $script_url/component/backup-data -O /etc/aisheescript/menu/backup-data && chmod +x /etc/aisheescript/menu/backup-data
wget -q $script_url/component/craete-database -O /etc/aisheescript/menu/craete-database && chmod +x /etc/aisheescript/menu/craete-database
wget -q $script_url/component/autobackup-off -O /etc/aisheescript/menu/autobackup-off && chmod +x /etc/aisheescript/menu/autobackup-off
wget -q $script_url/component/add-site -O /etc/aisheescript/menu/add-site && chmod +x /etc/aisheescript/menu/add-site
wget -q $script_url/component/autobackup -O /etc/aisheescript/menu/autobackup && chmod +x /etc/aisheescript/menu/autobackup
wget -q $script_url/component/delete-database -O /etc/aisheescript/menu/delete-database && chmod +x /etc/aisheescript/menu/delete-database
wget -q $script_url/component/delete-site -O /etc/aisheescript/menu/delete-site && chmod +x /etc/aisheescript/menu/delete-site
wget -q $script_url/component/park-domain -O /etc/aisheescript/menu/park-domain && chmod +x /etc/aisheescript/menu/park-domain
wget -q $script_url/component/redirect-domain -O /etc/aisheescript/menu/redirect-domain && chmod +x /etc/aisheescript/menu/redirect-domain
wget -q $script_url/component/server-upgrade -O /etc/aisheescript/menu/server-upgrade && chmod +x /etc/aisheescript/menu/server-upgrade
wget -q $script_url/component/list-website -O /etc/aisheescript/menu/list-website && chmod +x /etc/aisheescript/menu/list-website
wget -q $script_url/component/change-pass-vps -O /etc/aisheescript/menu/change-pass-vps && chmod +x /etc/aisheescript/menu/change-pass-vps
wget -q $script_url/component/permission-server -O /etc/aisheescript/menu/permission-server && chmod +x /etc/aisheescript/menu/permission-server

clear
cat > "/root/banned/aisheescript-info.txt" <<END
=========================================================================
                           Control VPS
=========================================================================
Call the menu vps: aisheevps

Website Main: http://$svdomain/ (hoac http://$svip/)
Link phpMyAdmin: http://$svdomain:$svport/ (hoac http://$svip:$svport/)
Server status: http://$svdomain:$svport/vpsinfo/ (hoac http://$svip:$svport/vpsinfo/)
Zend OPcache status: http://$svdomain:$svport/op.php (hoac http://$svip:$svport/op.php)
MySQL root password: $root_password

Support site http://aishee.net
END

printf "=========================================================================\n"
printf "AisheeScript setup complete... \n"
printf "=========================================================================\n"
printf "Website Main: http://$svdomain/ or http://$svip/\n"
printf "=========================================================================\n"
printf "Link phpMyAdmin: http://$svdomain:$svport/ \n or http://$svip:$svport/\n"
printf "=========================================================================\n"
printf "Folder source code: /home/$svdomain/public_html/\n"
printf "=========================================================================\n"
printf "Server status: http://$svdomain:$svport/vpsinfo/ \n hoac http://$svip:$svport/vpsinfo/ \n"
printf "=========================================================================\n"
printf "Zend OPcache status: http://$svdomain:$svport/op.php \n hoac http://$svip:$svport/op.php \n"
printf "=========================================================================\n"
printf "MySQL root password: $root_password \n"
printf "=========================================================================\n"
printf "Infomation script: /root/banned/aisheescript_info.txt \n"
printf "=========================================================================\n"
printf "Using port 3108 connect ssh remote server.\n"
printf "=========================================================================\n"
printf "Call menu aisheescript using: \"aisheevps\" on SSH.\n"
printf "If can support, access: http://aishee.net/\n"
printf "=========================================================================\n"
printf "Reboot Server on 3s.... \n\n"
sleep 3
reboot
exit

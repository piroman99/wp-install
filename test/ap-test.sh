#!/bin/bash

main () {
    write_secret_data
    update_upgrade
    install_apache2
    install_php_fpm
    setting_apache_fpm
    setting_nginx
    setting_conf_nginx
    gzip_nginx
    install_mod_rpaf
    app_install
    setting_up_php
#    setting_up_php_7_3
    mysql_install
    create_databases
    postfix_install
    install_wordpress
    ufw_setting
    reload_services
    setting_ssl
}

info () {
    lgreen='\033[1;32m'
    nc='\033[0m'
    printf "${lgreen}[info] ${@}${nc}\n"
}

write_secret_data () {
    secret_data="./secret_data.txt"
    echo "Mysql root password === $password_mysql
Admin Wordpress User=${admin_wp} 
Password Admin WP = ${admin_wp_password}" >> "$secret_data"
}

update_upgrade () {
    info "Update and upgrade OS"
    add-apt-repository -y ppa:ondrej/php
    apt update && apt upgrade -y
    info "System updated" 
}

ufw_setting () {
    info "Block all ports except protocol ports: SSH, HTTP, HTTPS, FTP"
    ports=( "ssh" "http" "https" "ftp" "postfix")
    for port in ${ports[@]}; do
        ufw allow $port
    done
    ufw deny 8080
    info "Firewall configured"
}

postfix_install () {
    echo "postfix postfix/mailname string custom.adminforum.online" | debconf-set-selections
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
    apt-get install -y postfix
#inet_interfaces = loopback-only  >> /etc/postfix/main.cf
}


lamp_install () {
    info "Install LAMP server"
    apt install -y tasksel
    tasksel install lamp-server
    info "LAMP server installed successful"
}

certbot_get_certs () {
    info "Getting SSL certificates from Let's Encrypt"
    add-apt-repository -y ppa:certbot/certbot
    apt-get update
    apt-get install -y python-certbot-nginx
    echo "A" | certbot certonly --webroot -w /var/www/"${environment[domain]}" -d "${environment[domain]}" --email admin@"${environment[domain]}"    
}

change_url () {
    wp option update siteurl $url --allow-root --path=/var/www/"${environment[domain]}"/
}

setting_ssl () {
    a_record=$( dig ${environment[domain]} +short)
    echo "$a_record"
    if [ "$ip" == "$a_record" ] ; then
 	echo "Domain ${environment[domain]} delegate to current server"
        certbot_get_certs
        setting_nginx_ssl
        fix_mixed_content
        cron_certbot
        reload_services
        change_url
	exit 0
    else
        echo "Domain ${environment[domain]} is not delegate to current server"
    fi
}

setting_conf_nginx () {
    sed -i 's/.*upload_max_filesize.*/upload_max_filesize = 32M/' "${path_php}"
    sed -i 's/.*upload_max_filesize.*/upload_max_filesize = 32M/' "${path_to_php_ini}"  
}

gzip_nginx () {
    sed "/gzip on;/ a\\
\tgzip_disable "msie6"; \n\
\tgzip_vary on; \n\
\tgzip_proxied any; \n\
\tgzip_comp_level 6; \n\
\tgzip_buffers 16 8k; \n\
\tgzip_http_version 1.1; \n\
\tgzip_min_length 256; \n\
\tgzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype image/svg+xml image/x-icon; \ " /etc/nginx/nginx.conf > /tmp/nginx.conf
    cat /tmp/nginx.conf > /etc/nginx/nginx.conf
}


setting_nginx_ssl () {
    info "Setting up nginx"
echo "server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 301 https://\$host\$request_uri;
}

server {
    listen              443 ssl;
    server_name         "${environment[domain]}";
    ssl_certificate      /etc/letsencrypt/live/"${environment[domain]}"/fullchain.pem;
    ssl_certificate_key  /etc/letsencrypt/live/"${environment[domain]}"/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_protocols TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384";

    client_max_body_size 32M;

    location /.well-known {
        root /var/www/html;
    }

    location / {
       proxy_pass http://localhost:8080;
       include /etc/nginx/proxy_params;
    }
}" > /etc/nginx/sites-available/"${environment[domain]}"
    info "Nginx configured"
}

cron_certbot () {
    crontab -l > wp-cron
    echo "00 1 * * * certbot renew --renew-hook 'systemctl reload nginx'" > wp-cron
    crontab wp-cron
}


setting_nginx () {
    apt install -y nginx
    rm /etc/nginx/sites-enabled/default
echo "server {
    listen 80;
    server_name localhost;

    location / {
       proxy_pass http://localhost:8080;
       include /etc/nginx/proxy_params;
    }
}" > /etc/nginx/sites-available/"${environment[domain]}"

    ln -s /etc/nginx/sites-available/"${environment[domain]}" /etc/nginx/sites-enabled/"${environment[domain]}"
}

install_apache2 () {
    apt install -y apache2 && a2dissite 000-default
    echo 'Listen 8080' | tee /etc/apache2/ports.conf
    service apache2 start
}

install_php_fpm () {
    apt install -y php-fpm
    wget https://mirrors.edge.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
    dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
}

setting_apache_fpm () {
    echo "<VirtualHost *:8080>
        ServerName localhost
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/"${environment[domain]}"

        ErrorLog \${APACHE_LOG_DIR}/"${environment[domain]}".log
        CustomLog \${APACHE_LOG_DIR}/"${environment[domain]}".log combined

        <Directory /var/www/>
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
</VirtualHost>
" > /etc/apache2/sites-available/"${environment[domain]}".conf

        a2enmod actions ; a2enmod rewrite

    echo "<IfModule mod_fastcgi.c>
AddHandler fastcgi-script .fcgi
FastCgiIpcDir /var/lib/apache2/fastcgi
AddType application/x-httpd-fastphp .php
Action application/x-httpd-fastphp /php-fcgi
Alias /php-fcgi /usr/lib/cgi-bin/php-fcgi
FastCgiExternalServer /usr/lib/cgi-bin/php-fcgi -socket /run/php/php7.2-fpm.sock -pass-header Authorization
<Directory /usr/lib/cgi-bin>
Require all granted
</Directory>
</IfModule>" > /etc/apache2/mods-enabled/fastcgi.conf
}

install_mod_rpaf () {
    apt install -y unzip build-essential apache2-dev
    cd /tmp/ && wget https://github.com/gnif/mod_rpaf/archive/stable.zip
    unzip stable.zip && cd mod_rpaf-stable/
    make && make install

    echo LoadModule rpaf_module /usr/lib/apache2/modules/mod_rpaf.so > /etc/apache2/mods-available/rpaf.load
echo "<IfModule mod_rpaf.c>
RPAF_Enable             On
RPAF_Header             "${environment[ip]}"
RPAF_ProxyIPs           "${environment[ip]}"
RPAF_SetHostName        On
RPAF_SetHTTPS           On
RPAF_SetPort            On
</IfModule>" > /etc/apache2/mods-available/rpaf.conf

}

reload_services () {
    a2ensite "${environment[domain]}"
    service apache2 restart
    service nginx restart
    service postfix restart
}

install_wordpress () {
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    wp core download --locale="${environment[locale]}" --allow-root --path="/var/www/${environment[domain]}"
    wp core config --dbname="${database_name}" --dbuser="${database_name}" --dbpass="${password_user_db}" --dbhost=localhost --dbprefix=wp_ --path="/var/www/${environment[domain]}" --allow-root
    wp core install --url="$url" --title=Blog-"${environment[domain]}" --admin_user="${admin_wp}" --admin_password="${environment[wp-password]}" --admin_email=webmaster@"${environment[domain]}" --allow-root --path="/var/www/${environment[domain]}"
    chown -R www-data:www-data /var/www/${environment[domain]}/

}

fix_mixed_content () {
    sed "/WP_CACHE_KEY_SALT/ a\
define('FORCE_SSL', true);\n\
define('FORCE_SSL_ADMIN',true);\ " /var/www/"${environment[domain]}"/wp-config.php > /tmp/wp-config.tmp.php

    sed "/table_prefix/ a\
if (strpos(\$_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false)\n\
        \$_SERVER['HTTPS']='on';\ " /tmp/wp-config.tmp.php  > /var/www/"${environment[domain]}"/wp-config.php
}

setting_up_php () {
    apt-get -y install php7.2 libapache2-mod-php7.2
    apt install -y \
        php-curl \
        php-gd \
        php-mbstring \
        php-xml \
        php-xmlrpc \
        php-soap \
        php-intl \
        php-zip

    apt install php7.2-mysqli || apt install php7.0-mysqli

    sed -i 's/.*realpath_cache_size.*/realpath_cache_size = 4096k/' "$path_php"
    sed -i 's/.*max_input_vars.*/max_input_vars = 1000/' "$path_php"
}

setting_up_php_7_3 () {
    apt install -y \
        php7.3 \
	php7.3-bcmath \
	php7.3-imagick \
}

mysql_install () {
    info "Install mysql-server"
    echo "mysql-server mysql-server/root_password password ${password_mysql}" | debconf-set-selections
    echo "mysql-server mysql-server/root_password_again password ${password_mysql}" | debconf-set-selections
    apt-get -y install mysql-server
    info "Mysql-server installed successful"
}

create_databases () {
    mysql -uroot -p"${password_mysql}"<<MYSQL_SCRIPT
    CREATE DATABASE ${database_name} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
    GRANT ALL ON ${database_name}.* TO '${database_name}'@'localhost' IDENTIFIED BY '${password_user_db}';
    FLUSH PRIVILEGES;
MYSQL_SCRIPT
    
}

app_install () {
    info "Install update and apps, zram-config ..."
    apt update -y && apt upgrade -y
    apt install -y \
        zram-config \
        debconf-utils
    info "Installation completed"
}

###Setting environment###

ip=`wget -q -4 -O- http://icanhazip.com`
admin_wp_password=$( date +%s | sha256sum | base64 | head -c 32 ; echo )

declare -A environment

keys=( $( echo ${@} | sed "s/\-\-//g" ) )

environment=( [domain]=localhost
              [ip]="${ip:=127.0.0.1}"
              [locale]=ru_RU
              [wp-password]=$admin_wp_password
)

for i in ${keys[@]} ; do
   environment[$(echo $i | cut -d'=' -f1)]=$(echo $i | cut -d'=' -f2)
   if [ "$(echo $i | cut -d'=' -f1)" == "ssl" ] ; then
       setting_ssl 
   fi
done

a_record=$( dig ${environment[domain]} +short)

if [ "$ip" == "$a_record" ] ; then
        echo "Domain ${environment[domain]} delegate to current server"
        url="https://${environment[domain]}"
    else
        echo "Domain ${environment[domain]} is not delegate to current server"
        url="http://${environment[ip]}"
fi

###System environment
path_php="/etc/php/7.2/apache2/php.ini"
path_to_php_ini="/etc/php/7.2/fpm/php.ini"
path_wp_config="/var/www/"${environment[domain]}"/wp-config.php"
database_name=$( echo "${environment[domain]}" | sed "s/\.//g" )
admin_wp="admin"
password_user_db=$( date +%s | sha256sum | base64 | head -c 32 ; echo )
password_mysql=$( openssl rand -base64 16 )
####################

main

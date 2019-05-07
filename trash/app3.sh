#/bin/bash

echo "Write you domain( example: domain.com ): " ; read var
domain=${var:-localhost}

ip_default=$( ip route get 8.8.8.8 | head -1 | cut -d' ' -f8 )
echo "Write you ip-address: $ip_default Сorrectly? (press: enter) :"; read ip_var
ip=${ip_var:-$ip_default}
echo $domain $ip

path_php="/etc/php/7.2/apache2/php.ini"
password_mysql=$( openssl rand -base64 16 )
password_user_db=$( date +%s | sha256sum | base64 | head -c 32 ; echo )
secret_data="./secret_data.txt"
path_wp_config="/var/www/"$domain"/wp-config.php"
database_name=$( echo "$domain" | sed "s/\.//g" )
echo "Mysql password === $password_mysql" >> "$secret_data"
echo "User $domain password === $password_user_db" >> "$secret_data"

keys=(
    --no-ask
)

value=(
    "main"
)

main () {
    update_upgrade
    install_apache2
    install_php_fpm
    setting_apache_fpm
    setting_nginx
    install_mod_rpaf
    app_install
    setting_up_php
    mysql_install
    create_databases
    install_wordpress
    blocker_apache_outboard
    ufw_setting
    reload_services
}

info () {
    lgreen='\033[1;32m'
    nc='\033[0m'
    printf "${lgreen}[info] ${@}${nc}\n"
}

update_upgrade () {
    apt update && apt upgrade -y 
}

ufw_setting () {
    ports=( "ssh" "http" "https" "ftp" )
    for port in ${ports[@]}; do
        ufw allow $port
    done
    ufw deny 8080
}

lamp_install () {
    info "Install LAMP server"
    apt install -y tasksel
    tasksel install lamp-server
    info "LAMP server installed successful"
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
}" > /etc/nginx/sites-available/"${domain}"

    ln -s /etc/nginx/sites-available/"${domain}" /etc/nginx/sites-enabled/"${domain}"
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
        #DocumentRoot /var/www/"${domain}"

        ErrorLog \${APACHE_LOG_DIR}/"${domain}".log
        CustomLog \${APACHE_LOG_DIR}/"${domain}".log combined

        <Directory /var/www/html/"${domain}">
            AllowOverride All
        </Directory>
</VirtualHost>
" > /etc/apache2/sites-available/${domain}.conf

        a2enmod actions

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
RPAF_Header             "${ip}"
RPAF_ProxyIPs           "${ip}"
RPAF_SetHostName        On
RPAF_SetHTTPS           On
RPAF_SetPort            On
</IfModule>" > /etc/apache2/mods-available/rpaf.conf

}

reload_services () {
    a2ensite "${domain}"
    service apache2 restart
    service nginx restart
}

install_wordpress () {
    cd /tmp
    curl -O https://wordpress.org/latest.tar.gz
    tar xzvf latest.tar.gz
    touch /tmp/wordpress/.htaccess
    cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
    mkdir -p /tmp/wordpress/wp-content/upgrade
    mkdir -p /var/www/${domain}
    sudo cp -a /tmp/wordpress/. /var/www/${domain}
    sudo chown -R www-data:www-data /var/www/${domain}
    sudo find /var/www/"${domain}"/ -type d -exec chmod 750 {} \;
    sudo find /var/www/"${domain}"/ -type f -exec chmod 640 {} \;

    SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
    STRING='put your unique phrase here'
    printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s "$path_wp_config"

    sed -i -e "s/database_name_here/${database_name}/" "$path_wp_config"
    sed -i -e "s/username_here/${database_name}/" "$path_wp_config"
    sed -i -e "s/password_here/${password_user_db}/" "$path_wp_config"
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

    sed -i 's/.*realpath_cache_size.*/realpath_cache_size = 4096k/' "$path_php"
    sed -i 's/.*max_input_vars.*/max_input_vars = 1000/' "$path_php"
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

if [ "${#@}" -gt 0 ]; then
    output_key="${@}"
    count=-1
    for key in "${keys[@]}" ; do
        count=$(( $count + 1 ))
        if [ $key == $output_key ]; then
           "${value[$count]}"
        fi
    done
fi

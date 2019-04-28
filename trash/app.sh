#/bin/bash

path_php="/etc/php/7.0/apache2/php.ini"


keys=(
    --no-ask
    --lamp
    --sql
    --setting-php
    --ufw
)

value=(
    "main"
    "lamp_install"
    "mysql_install"
    "setting_up_php"
    "ufw_setting"
)

info () {
    lgreen='\033[1;32m'
    nc='\033[0m'
    printf "${lgreen}[info] ${@}${nc}\n"
}

ufw_setting () {
    ports=( "ssh" "http" "https" "ftp" )
    for port in ${ports[@]}; do
        ufw allow $port
    done
}

lamp_install () {
    info "Install LAMP server"
    apt install -y tasksel
    tasksel install lamp-server
    info "LAMP server installed successful"
}

setting_up_php () {
    sed -i 's/.*realpath_cache_size.*/realpath_cache_size = 4096k/' "$path_php"
    sed -i 's/.*max_input_vars.*/max_input_vars = 1000/' "$path_php"
}

mysql_install () {
    info "Generate password"
    password=$( openssl rand -base64 16 ) && echo "Mysql password === $password" > secret_data.txt
    info "Install mysql-server"
    echo "mysql-server mysql-server/root_password password $password" | debconf-set-selections
    echo "mysql-server mysql-server/root_password_again password $password" | debconf-set-selections
    apt-get -y install mysql-server
    info "Mysql-server installed successful"
}

app_install () {
    info "Install update and apps, zram-config ..."
    apt update -y && apt upgrade -y
    apt install -y \
        zram-config \
        debconf-utils
    info "Installation completed"
}

main () {
    info "Firewall setup"
    app_install
    lamp_install
    mysql_install
    ufw_setting
    info "Firewall setup is complete successful"
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

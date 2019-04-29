 #!/bin/bash

#А тут надо как то узнать домен, e-mail админа, и может быть пароль админа из файла или консоли прочитать.
wpmysqlpassword=$(cat /dev/urandom | tr -d -c 'a-zA-Z0-9' | fold -w 15 | head -1) #это плохо, но сервер пустой
 
wpdomain=$1 #Первый параметр домен
wpadminmail=$2 #второй мыл админа вп - и походу его надо в кавычки заключать
wpadminpass=$3 #пароль вордпрес - тут опять проблема с спецсимволами
wplocale=$4 #локаль wp  - ну допусти en_US или ru_RU
scriptdir=$(pwd) #запомнинаем где мы запустили скрипт
 
# и в Продакшен
#Кстати, на новом сервере следующим строкам может помешать стартующий с системой unatendent updates
#так что тут должен быть какой то if, а то неудобно.

apt update -y #ну надо
apt upgrade -y #очень надо
apt install -y zram-config #Я художник, я так вижу
apt install -y tasksel # Потому что я ленивая #опа
apt install -y lamp-server^ # Все упрощаем
#mysql_secure_installation - я не знаю как автоматом без ввода root пароля
#apt install -y nginx #Куда же без него - но связку еще надо настроить
#вот тут настроили связки nginx-apache
#А тут подкрутили все под максимум производительности

#Включаем файрвол
ufw allow ssh
ufw allow http
ufw allow https 
ufw allow 25
ufw allow dns
#на самом деле нужно добавить несколько еще правил - но как. по одному что ли
echo "y" | sudo ufw enable #грязный хак с ответом да.

#Тут мы еще решим вопрос с DNS и SSL

#ставим wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

#создаем бд
# basename, username, password - заменить на свои значения.
DBNAME=wordpress
DBUSER=wordpress
DBPASS=$wpmysqlpassword
 
# Переменная пароля root-пользователя mysql/mariadb, для входа в консоль.
ROOTPASS="fffuuuffffb" #от рута работает любой, а пустой не принимает
 
# Переменная каталога в котором находятся базы данных - НЕ ИЗМЕНЯТЬ!!!
DBDIR=/var/lib/mysql/
 
# -----------------------------------
# 1 - Создание базы данных для сайта.
# -----------------------------------
 
echo "Создаю базу данных…"
 
if [ -e "$DBDIR"/"$DBNAME" ]; then
echo -e "\nБаза с таким именем уже есть. Выбери другое имя для базы данных.
Работа скрипта остановлена." && exit #на самом деле тут в этом случае надо базу и юзера стереть
#что то типа mysql mysql -u root -p"$ROOTPASS" -e "drop user "$DBUSER"@'localhost';
# mysql -u root -p"$ROOTPASS" -e "drop database "$DBNAME";
fi
 
# Создание пользователя (раскомментировать если нужен новый пользователь).
mysql -u root -p"$ROOTPASS" -e "create user "$DBUSER"@'localhost' identified by '$DBPASS';"
 
# Создание базы данных и назначение привилегий пользователя.
mysql -u root -p"$ROOTPASS" -e "create database "$DBNAME"; grant all on "$DBNAME".* to "$DBUSER"@'localhost'; flush privileges;"
 
if [ "$?" != 0 ]; then
echo -e "\nВо время создания базы возникла ошибка.
Работа скрипта остановлена." && exit
fi
 
echo -e "\nБаза данных: "$DBNAME"
Пользователь базы данных: "$DBUSER"
Пароль пользователя: "$DBPASS" "

#закончили создавать бд

rm -f /var/www/html/index.html #опусташаем папку
chown www-data /var/www/
chown www-data /var/www/html/
cd /var/www/html/ #как все сделаем наверное будет /var/www/ $domain/
#Загружаем wordpress c заданной локалью
sudo -u www-data HOME=/var/www env wp core download --locale=ru_RU --path=/var/www/html/ 
#wp core download --path=/var/www/html/ --locale=$locale --allow-root
rm -rf /var/www/.wp-cli/ #подчищаем за wp-cli

#Создаем конфиг wordpress
sudo -u www-data wp core config --dbname=wordpress --dbuser=wordpress --dbpass=$wpmysqlpassword --dbhost=localhost --dbprefix=wp_ --path=/var/www/html/ 
#wp core config --dbname=wordpress --dbuser=wordpress --dbpass=$wpmysqlpassword --dbhost=localhost --dbprefix=wp_ --allow-root

#устанавливаем wordpress
sudo -u www-data wp core install --url="$wpdomain" --title="My blog" --admin_user="admin" --admin_password="$wpadminpass" --admin_email="$wpadminmail" --path="/var/www/html/" 

#Активируем supercache
sudo -u www-data wp plugin install wp-super-cache 
sudo -u www-data wp plugin activate wp-super-cache
sudo -u www-data HOME=/var/www/ wp package install wp-cli/wp-super-cache-cli
sudo -u www-data HOME=/var/www/ wp rewrite structure '/%year%/%monthnum%/%postname%' #иначе не работает
#Активируем supercache уже внутри supercache
sudo -u www-data HOME=/var/www/ wp super-cache enable 



#Закончили
rm -f $scriptdir/wphosters.cfg
rm -f $scriptdir/install-wp.sh #Убираем следы нашего позора

#Предупреждаем о перезагрузке и ребутим"
echo "Pleae press any key to reebot now"
read -n 1
shutdown -r now #Семь бед - один ресет

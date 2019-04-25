 #!/bin/bash


 #А тут надо как то узнать домен, e-mail админа, и может быть пароль админа из файла или консоли прочитать.
 wpmysqlpassword=$(cat /dev/urandom | tr -d -c 'a-zA-Z0-9' | fold -w 15 | head -1) #это плохо, но сервер пустой
 
 
# и в Продакшен
#Кстати, на новом сервере следующим строкам может помешать стартующий с системой unatendent updates
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
ufw allow ssh # http https  на самом деле нужно добавить несколько правил - но как. по одному что ли
#ufw enable

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
Работа скрипта остановлена." && exit
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

find /var/www/html/ -delete #опусташаем папку
cd /var/www/html/ #как все сделаем наверное будет /var/www/ $domain/
#Загружаем wordpress c заданной локалью
wp core download --locale=ru_RU --allow-root --path=/var/www/html/ #wp core download --path=/var/www/html/ --locale=$locale --allow-root

#Создаем конфиг wordpress
wp core config --dbname=wordpress --dbuser=wordpress --dbpass=$wpmysqlpassword --dbhost=localhost --dbprefix=wp_ --path=/var/www/html/ --allow-root
#wp core config --dbname=wordpress --dbuser=wordpress --dbpass=$wpmysqlpassword --dbhost=localhost --dbprefix=wp_ --allow-root

#устанавливаем wordpress
#wp core install --url="вашдомен.ru"  --title="My blog" --admin_user="admin" --admin_password="пароль_администратора" —admin_email="мойemail@email.ru" --allow-root

#Активируем supercache
#wp plugin install wp-super-cache --allow-root
#wp plugin activate wp-super-cache --allow-root
#wp super-cache enable  --allow-root



#Закончили
rm -f wphosters.cfg
rm -f install-wp.sh #Убираем следы нашего позора

#Предупреждаем о перезагрузке и ребутим"
echo "Pleae press any key to reebot now"
read -n 1
shutdown -r now #Семь бед - один ресет

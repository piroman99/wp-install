 #!/bin/bash


 #А тут надо узнать домен, e-mail админа, и может быть пароль админа из файла или консоли прочитать.
 
 
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

#cd /var/www/domain/
#Загружаем wordpress c заданной локалью
#wp core download --locale=$locale --allow-root

#Создаем конфиг wordpress
#wp core config --dbname=wordpress --dbuser=wordpress --dbpass=$password --dbhost=localhost --dbprefix=wp_ --allow-root

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

 #!/bin/bash


 #А тут надо узнать домен, e-mail админа, и может быть пароль админа
 
# и в Продакшен
apt update -y #ну надо
apt upgrade -y #очень надо
apt install -y zram-config #Я художник, я так вижу
apt install -y tasksel # Потому что я ленивая #опа
apt install -y lamp-server^ # Все упрощаем
#mysql_secure_installation - я не знаю как автоматом без ввода root пароля
#apt install -y nginx #Куда же без него - но связку еще надо настроить
#вот тут настроили связки nginx-apache
ufw allow ssh # http https  на самом деле нужно добавить несколько правил - но как. по одному что ли
#ufw enable


#Тут мы еще решим вопрос с DNS и SSL

#ставим wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp



#Закончили
rm -f install-wp.sh #Убираем следы нашего позора
shutdown -r now #Семь бед - один ресет

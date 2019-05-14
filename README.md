# wp-install
Simpe Wordpress install for fast working

Futures
--- 
All in one to start Wordpress in the VPS or bare iron.  Zram + Wp caching + Let's Encrypt + PHP-FPM 7.2 + LAMP + Nginx

Soon
---
Simple DNS for one domain, Outgoing Mail , fine tuning 


#Install
----

You need VPS or bare iron with Ubuntu 18.04 

Yoo need login as root to this VPS

type:

wget -O https://raw.githubusercontent.com/piroman99/wp-install/master/app_release.sh

bash app_release.sh --domain=youdomain.com --wp-password=youwpadminpass --local=en_US

After install, please reboot and then open you domain. Now you can login to wordpress. 

Use login admin and pass - youwpadminpass

Please, do not use default password, change it
----


Donate (only if you want)
---
paypal https://paypal.me/piroma

yandex https://money.yandex.ru/to/4100187198150

I am waiting for suggestion , issues and pull requests from you. 
Also, you can always help me to correct this text.
Thank you.




Below is the text of the Russian technical specifications. Please do not try to understand it. Wait.


Как бы ТЗ
---

цель
консольная установка производительного вордпресс

итак что ставим

1 этап
---

apt-get update && apt-get dist-upgrade

zramctl ? Ну если рама меньше или равно 4г

далее

апаче
мускуль
php

Например, через 
tasksel install lamp-server ?

в пхп опенбейсдир должен бытьотключен, сам пхп был модулем, наверное ( спорно, но мы делаем быструю машину), realpatchcachesize 4Mb и не знаю что еще для скорости. Для один сервер - один сайт


нгнигкс и посмотреть что бы воркерс было авто.

файрвол ufw

бинд? Или чем мы мх отправим на другую почту

SSL и леценкрипт в частности.
https://invs.ru/support/chastie-voprosy/kak-podklyuchit-besplatnyy-ssl-sertifikat-let-s-encrypt-dlya-apache-na-servere-s-ubuntu-17-04/
или https://www.webhive.ru/2018/05/17/acme-sh-great-certbot-alternative/
Так или иначе, нужен живой DNS

2 этап
---

сам вордпрес
https://www.internet-technologies.ru/articles/ustanavlivaem-wordpress-s-pomoschyu-komandnoy-stroki.html
https://techlist.top/ustanovka-wordpress-odnoj-knopkoj/

Подозреваю через wp-cli

3 этап
-----

плагин суперкеш (supercache)
Установка и активация прям из коробки из wp-cli
Если не даст - другой плагин.
Плагин Filemanager


4 этап
------
плагин переноса из другого места. и бэкапа 
плагин тюнинга
( или инструкция - меню для wp-cli )
Плагин скорости вордпресс


Установка,
---
подозреваю что то типа
curl -O http://fubar.ru/instal-wp.sh
bash install-wp.sh

Для хостеров делаем автоустановку через файлик wphosters.cfg и ключ -no_ask 

Далее спрашиваем домен ( для SSL), по умолчанию предлагаем имя сервера, Локаль ( по ней определяем какую версию вп скачать) настройку DNS, мыл админа wp, логин и пароль админа (может генерим) что еще? и сетупим.

В конце
rm hosters.cfg
rm install-wp.sh 
shutdown -r now

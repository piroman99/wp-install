# wp-install
Simpe Wordpress install for fast working


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


бинд? Или чем мы мх отправим на другую почту

SSL и леценкрипт в частности.

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


4 этап
------
плагин переноса из другого места. и бэкапа 
плагин тюнинга


Установка,
---
подозреваю что то типа
curl -O http://fubar.ru/instal-wp.sh
bash install-wp.sh

Далее спрашиваем домен ( для SSL), по умолчанию предлагаем имя сервера, Локаль ( по ней определяем какую версию вп скачать) настройку DNS, мыл админа wp, логин и пароль админа (может генерим) что еще? и сетупим.

А потому rm install-wp.sh 
shutdown -r now

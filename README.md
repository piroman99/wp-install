# wp-install
Simpe Wordpress install for fast working. 

Futures
--- 
All in one to start Wordpress in the VPS or bare iron.  Zram + Wp caching + Let's Encrypt + PHP-FPM 7.3 + LAMP + Nginx +PHP 7.3 , Postfix for outgoing mail, gzip on Nginx, imagick and bcmath in PHP. Support DNSmanager as Slave<br>
Wordpress install based on wp-cli . Always latest Wordpress and plugin version after install

Soon
---
Simple DNS for one domain,  fine tuning <br>
test process in https://github.com/piroman99/wp-install/tree/master/test <br>
We need your help and participation<br>

#Install
----

You need VPS or bare iron with Ubuntu 18.04 

login as root

type:

wget https://raw.githubusercontent.com/piroman99/wp-install/master/app_release.sh

After you can:

#install Wordpress:

bash app_release.sh --domain=youdomain.com --wp-password=youwpadminpass --local=en_US


#tune DNSmanager for Ruweb.net - hardcoded, not recommended for other hostings:

bash app_release.sh --domain=youdoman.com --user_dnsmgr=user_dnsmanager --pass_dnsmgr=pass_dnsmanager --domain1_dnsmgr=dnsmgr1.deserv.net --domain2_dnsmgr=dnsmgr2.deserv.net --dnsmgr

#Add SSL for this instalation if it was not previously installed:

bash app_release.sh --domain=youdoman.com --ssl


After install, please reboot server. Then open your domain in browser. Now you can login to wordpress. 

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



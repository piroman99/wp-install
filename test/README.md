new version WP INSTALL
---
Futures :PHP 7.3 , Postfix for outgoing mail, gzip on Nginx, imagick and bcmath in PHP <br>
Fixed bugs: allowoverdrive enable in .httaccess , upload limit in PHP and NGINX increased to 32 megabytes <br>  

Install
--
You need VPS or bare iron with Ubuntu 18.04 <br>

Login as root
<br>
type:
<br>
wget https://raw.githubusercontent.com/piroman99/wp-install/master/test/ap-test.sh
<br>
bash app-test.sh --domain=youdomain.com --wp-password=youwpadminpass --local=en_US
<br>

After install, please reboot and then open your domain in browser. Now you can login to wordpress.
<br>
Use login admin and pass - youwpadminpass

Please, do not use default password, change it
--

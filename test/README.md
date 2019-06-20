new version WP INSTALL
---
Futures :PHP 7.3 , Postfix for outgoing mail, gzip on Nginx, imagick and bcmath in PHP. Support DNSmanager as Slave<br>
Fixed bugs: allowoverdrive enable in .httaccess without dirty hack, upload limit in PHP and NGINX increased to 8 megabytes <br>  

Install
--
You need VPS or bare iron with Ubuntu 18.04 <br>

Login as root
<br>
type:
<br>
wget https://raw.githubusercontent.com/piroman99/wp-install/master/test/app_test.sh
<br>
bash app_test.sh --domain=youdoman.com --wp-password=youwpadminpass --local=en_US
#install Wordpress

<br>
bash app_test.sh --domain=youdoman.com  --user_dnsmgr=user_dnsmanager --pass_dnsmgr=pass_dnsmanager --domain1_dnsmgr=dnsmgr1.deserv.net --domain2_dnsmgr=dnsmgr2.deserv.net --dnsmgr 
#tune DNSmanager for Ruweb.net - hardcoded, not recommended for other hostings

<br>
 bash app_test.sh --domain=youdoman.com --ssl 
 #Add SSL f it was not previously installed
<br>

After install, please reboot and then open your domain in browser. Now you can login to wordpress.
<br>
Use login admin and pass - youwpadminpass

Please, do not use default password, change it
--

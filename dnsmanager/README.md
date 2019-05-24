В DNSManager можно использовать скрипт dnsmgrupdate


Качаем скрипт:
curl -ku: https://:@svn.deserv.net/dnsmgrupdate/dnsmgrupdate
(Логин и пароль для скачивания - пустые!)
Кладем его по пути: /root/dnsmgr/dnsmgrupdate
Даем права на выполнение: chmod +x /root/dnsmgr/dnsmgrupdate
И создаем конфиг: /root/dnsmgr/dnsmgrupdate.conf

В конфиге описываем параметры вида:
NAMEDPATH=/etc/namedb
MASTERIP=11.22.33.44
DNSMGRURL=https://dnsmgr1.server.net/manager/dnsmgr?out=text&authinfo=user:pass
DNSMGRURL=https://dnsmgr2.server.net/manager/dnsmgr?out=text&authinfo=user:pass
CHANGESONLY=yes
CHECKMASTER=yes

основные настройки:
NAMEDPATH - путь либо к директории в которой создаются файлы зон (обычно /etc/namedb), либо к конфигу, в котором прописываются файлы зон
MASTERIP - ip-адрес вашего сервера (с него будут забираться зоны)
DNSMGRURL - URL dnsmgr-а с юзером и паролем (url-ов может быть больше, чем один)
CHANGESONLY - Выводить только изменения
CHECKMASTER - Игнорировать зоны с другим MASTERIP

запускаем скрипт и проверяем, что он отрабатывает, далее в cron ставим задание:
* * * * * [ ЗНАЧЕНИЕ_ИЗ_NAMEDPATH -ot /tmp/dnsmgrupdate.stamp ] || (date; touch /tmp/dnsmgrupdate.stamp; /root/dnsmgr/dnsmgrupdate) >>/var/log/dnsmgrupdate

Смысл работы следующий: команда выполняется каждую минуту, если с момента предыдущего запуска изменился список доменов на локальном сервере, запускается скрипт, который получает зоны со всех slave-серверов, сверяет с локальным списком и синхронизирует их на slave-серверах. Локальный список доменов получается путем сканирования NAMEDPATH. (После передачи списка доменов на slave-сервера, slave-ы начинают делать запросы на MASTERIP для получения и синхронизации зон.)

Также в опциях BIND (в секции options обычно в named.conf) следует добавить:
Код:

notify explicit;
also-notify { 74.119.194.67; 185.12.92.10; };
allow-transfer { 74.119.194.67; 185.12.92.10; };

где 74.119.194.67 и 185.12.92.10 - IP-адреса вторичных ДНС-серверов.

PS: В CentOS для работы скрипта потребуется доустановить perl-LWP-Protocol-https:
Код:
yum install perl-LWP-Protocol-https

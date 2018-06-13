#/bin/bash
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
/usr/bin/mysqld_safe &
sleep 3

mysql -uroot -e "grant all on *.* to root@localhost identified by '${MYSQLPASSWORD}'; flush privileges;"

if [ ! -d "/var/lib/mysql/Yearning" ]; then
  mysql -uroot -p"$MYSQLPASSWORD" -e "create database Yearning character set 'utf8' collate 'utf8_general_ci' ;"
  python3 manage.py makemigrations
  python3 manage.py migrate
  echo "from core.models import Account; Account.objects.create_user(username='admin', password='Yearning_admin', group='admin',is_staff=1)" | python3 manage.py shell
fi


sed -i "s/8000/${YApiPort}/" /usr/share/nginx/html/static/js/app.b534e9fe0e47062ceee8.js
sed -i "56,56d"  /opt/Yearning/src/settingConf/settings.py
sed -i "55a \    '127.0.0.1:8080'," /opt/Yearning/src/settingConf/settings.py
sed -i "56a \    '${YHost}:${YPort}'" /opt/Yearning/src/settingConf/settings.py
sed -i "51,51d" /opt/Yearning/src/settingConf/settings.py
sed -i "50a \     CONF_DATA.ipaddress," /opt/Yearning/src/settingConf/settings.py
sed -i "51a \    '${YHost}:${YPort}'" /opt/Yearning/src/settingConf/settings.py
sed -i "s/ipaddress =.*/ipaddress=$HOST/" deploy.conf

/usr/sbin/nginx
/opt/Yearning/install/inception/bin/Inception --defaults-file=/opt/Yearning/install/inception/bin/inc.cnf &
python3 manage.py runserver 0.0.0.0:8000

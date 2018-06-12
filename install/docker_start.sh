#/bin/bash
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
/usr/bin/mysqld_safe &
sleep 3

mysql -uroot -e "grant all on *.* to root@localhost identified by '${MYSQLPASSWORD}'; flush privileges;"

if [ ! -d "/var/lib/mysql/Yearning" ]; then
  mysql -e "create database Yearning character set 'utf8' collate 'utf8_general_ci' ;"
  python3 manage.py makemigrations
  python3 manage.py migrate
  echo "from core.models import Account; Account.objects.create_user(username='admin', password='Yearning_admin', group='admin',is_staff=1)" | python3 manage.py shell
fi

sed -i "s/8000/${YPort}/" /usr/share/nginx/html/static/js/app.b534e9fe0e47062ceee8.js

sed -i "s/ipaddress =.*/ipaddress=$HOST/" deploy.conf

/usr/sbin/nginx
/opt/Yearning/install/inception/bin/Inception --defaults-file=/opt/Yearning/install/inception/bin/inc.cnf &
python3 manage.py runserver 0.0.0.0:8000

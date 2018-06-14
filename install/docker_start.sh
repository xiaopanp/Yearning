#/bin/bash
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
/usr/bin/mysqld_safe --datadir=/opt/mysql/data & sleep 10

mysql -uroot -e "grant all on *.* to root@localhost identified by 'root'; flush privileges;"
echo "-------------------------------修改密码---------------------"
if [ ! -d "/var/lib/mysql/Yearning" ]; then
  echo "-------------------------------初始化数据库---------------------"
  mysql -uroot -p"$MYSQLPASSWORD" -e "create database Yearning character set 'utf8' collate 'utf8_general_ci' ;"
  python3 manage.py makemigrations
  python3 manage.py migrate
  cd /opt/Yearning/src
echo "from core.models import Account; Account.objects.create_user(username='admin', password='"123456"', group='admin',is_staff=1)" | python3 manage.py shell
echo "from core.models import grained;grained.objects.get_or_create(username='admin', permissions={'ddl': '1', 'ddlcon': [], 'dml': '1', 'dmlcon': [], 'dic': '1', 'diccon': [], 'dicedit': '0', 'query': '1', 'querycon': [], 'user': '1', 'base': '1', 'dicexport': '0', 'person': []})" | python3 manage.py shell
fi


sed -i "s/8000/${YApiPort}/" /usr/share/nginx/html/static/js/app.b534e9fe0e47062ceee8.js
sed -i "s/8000/${YApiPort}/" /usr/share/nginx/html/static/js/app.b534e9fe0e47062ceee8.js
sed -i "56,56d"  /opt/Yearning/src/settingConf/settings.py
sed -i "55a \    '127.0.0.1:8080'," /opt/Yearning/src/settingConf/settings.py
sed -i "56a \    '${YHost}:${YPort}'" /opt/Yearning/src/settingConf/settings.py
sed -i "51,51d" /opt/Yearning/src/settingConf/settings.py
sed -i "50a \     CONF_DATA.ipaddress," /opt/Yearning/src/settingConf/settings.py
sed -i "51a \    '${YHost}:${YPort}'" /opt/Yearning/src/settingConf/settings.py
sed -i "s/ipaddress =.*/ipaddress=$HOST/" deploy.conf
sed -i "s/inception_remote_system_password =/inception_remote_system_password =${MYSQLPASSWORD}/" /opt/Yearning/install/inception/bin/inc.cnf

/usr/sbin/nginx
/opt/Yearning/install/inception/bin/Inception --defaults-file=/opt/Yearning/install/inception/bin/inc.cnf &
python3 manage.py runserver 0.0.0.0:8000

FROM centos

MAINTAINER xiaopanp 2018-06-14

EXPOSE 8000

EXPOSE 80

WORKDIR /tmp

RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && \
    rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm && \
    yum -y install wget gcc nginx mysql-community-server zlib* openssl-devel git; yum clean all

RUN wget https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tar.xz && tar xvf Python-3.6.4.tar.xz && \
    cd Python-3.6.4 && ./configure && make && make install && \
    rm -rf /tmp/Python* && mysql_install_db && chmod -R 777 /var/lib/mysql 

WORKDIR /opt/
 
COPY ./ /opt/Yearning/

RUN  cd /opt/Yearning/src && pip3 install -r requirements.txt

RUN cd /opt/Yearning/ && git pull && sleep 1 && \
    mkdir -p /opt/mysql/data && chmod -R 777 /opt/mysql/data && \
    # cp -rf /opt/Yearning/my.cnf /etc/my.cnf && \
    cp -rf /opt/Yearning/install/connections.py /usr/local/lib/python3.6/site-packages/pymysql/ && \
    cp -rf /opt/Yearning/install/cursors.py /usr/local/lib/python3.6/site-packages/pymysql/ && \
    cp -rf /opt/Yearning/install/docker_start.sh /usr/local/bin/ && \
    cp -rf /opt/Yearning/webpage/dist/* /usr/share/nginx/html/ && \
    cd /opt/Yearning/install/ && tar xvf inception.tar && \
    cp -fr /opt/Yearning/src/deploy.conf.template /opt/Yearning/src/deploy.conf && \
    cd /opt/Yearning/src && sed -i "s/backuppassword =.*/backuppassword = root/" deploy.conf && \
    cd /opt/Yearning/src && sed -i "s/password =.*/password = root/" deploy.conf && \
    chmod 755 /usr/local/bin/docker_start.sh
 
WORKDIR /opt/Yearning/src

ENTRYPOINT docker_start.sh

FROM centos:7.6.1810


# ----------------------------------------------------------------------
# Preparation

# yum config
WORKDIR /etc/yum.custom.repos.d/cache/yum/x86_64
WORKDIR /etc/yum.custom.repos.d/log
ADD ./config/yum.custom.conf /etc/yum.custom.repos.d/yum.custom.conf

# yum update & chache clear
RUN yum update -y && \
    yum -y install epel-release && \
    rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum clean all


# ----------------------------------------------------------------------
# Required compornent

RUN yum -y -c /etc/yum.custom.repos.d/yum.custom.conf --enablerepo=remi install \
    autoconf \
    automake \
    bison \
    bzip2-devel \
    crontabs \
    flex \
    gcc \
    gcc-c++ \
    gdbm-devel \
    gd-devel \
    gd-last \
    gmp-devel \
    jbigkit-libs \
    libargon2 \
    libc-client-devel \
    libcurl-devel \
    libdbi-devel \
    libedit \
    libicu62 \
    libicu-devel \
    libmcrypt-devel \
    libtidy-devel \
    libtiff \
    libtool \
    libwebp \
    libwebp-devel \
    libxml2-devel \
    libxslt \
    libxslt-devel \
    mailcap \
    make \
    pcre-devel \
    perl \
    re2c \
    readline-devel \
    wget \
    dos2unix && \
yum clean all


# ----------------------------------------------------------------------
# SSH Server

#ARG SSH_PASSWD
#ARG SSH_PORT

# sshd
#RUN yum -y -c /etc/yum.custom.repos.d/yum.custom.conf --enablerepo=remi install \
#    openssh-server
#COPY ./config/sshd_config /etc/ssh/
#RUN sed -i "s/SSH_PORT/${SSH_PORT}/g" /etc/ssh/sshd_config && \
#    echo "${SSH_PASSWD}" | chpasswd

#ADD ./config/ssh_setup.sh /tmp
#RUN chmod u+x /tmp/ssh_setup.sh && \
#    /tmp/ssh_setup.sh && \
#    rm -rf /tmp/ssh_setup.sh

# Expose
#EXPOSE ${SSH_PORT}


# ----------------------------------------------------------------------
# SSH Client

#RUN yum -y -c /etc/yum.custom.repos.d/yum.custom.conf --enablerepo=remi install \
#    openssh-clients

# ----------------------------------------------------------------------
# Web Server

ARG WEB_ROOT="/var/www/html"
ENV WEB_ROOT=${WEB_ROOT}
ARG WEB_PORT
ENV WEB_PORT=${WEB_PORT}

ARG SWEB_ROOT="/var/www/html"
ENV SWEB_ROOT=${SWEB_ROOT}
ARG SWEB_PORT
ENV SWEB_PORT=${SWEB_PORT}

ENV ORIGIN_DOC_ROOT="/var/www/html"

# Apache Httpd
RUN yum -y -c /etc/yum.custom.repos.d/yum.custom.conf --enablerepo=remi install \
    httpd \
    mod_ssl

# Expose
EXPOSE ${WEB_PORT}
EXPOSE ${SWEB_PORT}

# ----------------------------------------------------------------------
# Development Language

# PHP
ARG PHP_VERSION
RUN yum -y -c /etc/yum.custom.repos.d/yum.custom.conf --enablerepo=remi-${PHP_VERSION} install \
    php \
    php-bcmath \
    php-cli \
    php-common \
    php-devel \
    php-gd \
    php-intl \
    php-json \
    php-mbstring \
    php-mysqlnd \
    php-pdo \
    php-pecl-mcrypt \
    php-process \
    php-xml \
    php-pecl-redis

# php.ini
ARG PHP_INI_PATH
ENV PHP_INI_PATH=${PHP_INI_PATH}

RUN yum -y -c /etc/yum.custom.repos.d/yum.custom.conf --enablerepo=remi-${PHP_VERSION} install \
    composer \
    php-pear-phing

# xdebug
ARG XDEBUG_REMOTE_HOST
ARG XDEBUG_PORT
ENV XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST}
ENV XDEBUG_PORT=${XDEBUG_PORT}

RUN yum -y -c /etc/yum.custom.repos.d/yum.custom.conf --enablerepo=remi-${PHP_VERSION} install \
    php-pecl-xdebug

COPY ./config/15-xdebug.ini /etc/php.d/

# xhprof
ARG XHPROF_VERSION
ENV XHPROF_VERSION=${XHPROF_VERSION}
RUN mkdir -p /tmp/xhprof && \
    cd /tmp/xhprof && \
    wget https://pecl.php.net/get/xhprof-${XHPROF_VERSION}.tgz && \
    tar zxvf xhprof-${XHPROF_VERSION}.tgz && \
    cd xhprof-${XHPROF_VERSION}/extension/ && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    mkdir -p /usr/lib64/php/xhprof && \
    mv /tmp/xhprof/xhprof-${XHPROF_VERSION}/xhprof_lib /usr/lib64/php/xhprof/xhprof_lib && \
    mv /tmp/xhprof/xhprof-${XHPROF_VERSION}/xhprof_html /usr/lib64/php/xhprof/xhprof_html && \
    mkdir -p /var/log/xhprof && \
    chmod 777 /var/log/xhprof && \
    rm -rf /tmp/xhprof

COPY ./config/16-xhprof.ini /etc/php.d/


# ----------------------------------------------------------------------
# Entrypoint

ADD ./config/docker-entrypoint.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/docker-entrypoint.sh

# ----------------------------------------------------------------------
# User

# ENV USER=admin
# ユーザ作成
# USER ${USER}

#ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
#CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
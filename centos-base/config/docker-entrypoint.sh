#!/bin/bash
set -euo pipefail

# ----------------------------------------------------------------------
# Starting sshd ...
#/usr/sbin/sshd




if grep 'PHPINIDir' /etc/httpd/conf.d/php.conf >/dev/null; then
    echo "設定済み"
else

# ----------------------------------------------------------------------
# Setting Document Root ... (http)
mkdir -p ${WEB_ROOT}
sed -i "s#\"${ORIGIN_DOC_ROOT}\"#\"${WEB_ROOT}\"#g" /etc/httpd/conf/httpd.conf
sed -i "s#80#${WEB_PORT}#g" /etc/httpd/conf/httpd.conf

cat <<EOF > ${WEB_ROOT}/info.php
<?php
echo "(http)";
phpinfo();
EOF

# Setting Document Root ... (https)
mkdir -p ${SWEB_ROOT}
sed -i "s#\#DocumentRoot#DocumentRoot#g" /etc/httpd/conf.d/ssl.conf
sed -i "s#\"${ORIGIN_DOC_ROOT}\"#\"${SWEB_ROOT}\"#g" /etc/httpd/conf.d/ssl.conf
sed -i "s#443#${SWEB_PORT}#g" /etc/httpd/conf.d/ssl.conf

cat <<EOF > ${SWEB_ROOT}/info.php
<?php
echo "(https)";
phpinfo();
EOF

# ----------------------------------------------------------------------
# Allow .htaccess
cat <<EOF >> /etc/httpd/conf/httpd.conf
<Directory "${WEB_ROOT}">
    Options -Indexes
    AllowOverride All
    Order allow,deny
    Allow from all
</Directory>
EOF

cat <<EOF >> /etc/httpd/conf.d/ssl.conf
<Directory "${SWEB_ROOT}">
    Options -Indexes
    AllowOverride All
    Order allow,deny
    Allow from all
</Directory>
EOF

# ----------------------------------------------------------------------
# Change path for php.ini
cat <<EOF >> /etc/httpd/conf.d/php.conf
<IfModule php7_module>
    PHPINIDir "${PHP_INI_PATH}"
</IfModule>
EOF

# ----------------------------------------------------------------------
# Log console out (httpd.conf)
sed -i "s#ErrorLog \"logs/error_log\"#ErrorLog \"/dev/stderr\"#g" /etc/httpd/conf/httpd.conf
sed -i "s#    CustomLog#    \#CustomLog#g" /etc/httpd/conf/httpd.conf
sed -i "s#\#CustomLog \"logs/access_log\" common#CustomLog \"/dev/stdout\" common#g" /etc/httpd/conf/httpd.conf

# Log console out (ssl.conf)
sed -i "s#ErrorLog logs/ssl_error_log#ErrorLog \"/dev/stderr\"#g" /etc/httpd/conf.d/ssl.conf
sed -i "s#TransferLog logs/ssl_access_log#TransferLog \"/dev/stdout\"#g" /etc/httpd/conf.d/ssl.conf
sed -i "s#CustomLog logs/ssl_request_log#CustomLog \"/dev/stdout\"#g" /etc/httpd/conf.d/ssl.conf

# ----------------------------------------------------------------------
# Settings xdebug port ...
sed -i "s/XDEBUG_PORT/${XDEBUG_PORT}/g" /etc/php.d/15-xdebug.ini
sed -i "s/XDEBUG_REMOTE_HOST/${XDEBUG_REMOTE_HOST}/g" /etc/php.d/15-xdebug.ini

fi

# ----------------------------------------------------------------------
# Starting Exec ...
exec "$@"
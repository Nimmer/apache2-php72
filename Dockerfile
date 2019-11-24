FROM gabrieltakacs/alpine:latest
MAINTAINER Gabriel Takács <gtakacs@gtakacs.sk>

# Copy and add files first (to make dockerhub autobuild working: https://forums.docker.com/t/automated-docker-build-fails/22831/14)
COPY run.sh /run.sh

# Install Apache2, supervisor, PHP 7.2
RUN apk --no-cache --update add \
    apache2 \
    supervisor \
    php \
    php7-xml \
    php7-pgsql \
    php7-mysqli \
    php7-pdo_mysql \
    php7-mcrypt \
    php7-opcache \
    php7-curl \
    php7-json \
    php7-phar \
    php7-openssl \
    php7-ctype \
    php7-zip \
    php7-iconv \
    php7-soap \
    php7-zlib \
    php7-dom \
    php7-apache2 \
    php7-bcmath \
    php7-posix \
    memcached \
    imagemagick \
    postfix

# Install NPM & NPM modules (gulp, bower)
RUN apk --no-cache --update add \
    nodejs
RUN npm install  -g \
    gulp \
    bower

# php-fpm configuration
COPY php/php.ini /etc/php/php.ini

# Install composer
ENV COMPOSER_HOME=/composer
RUN mkdir /composer \
    && curl -sS https://getcomposer.org/download/1.2.1/composer.phar > composer.phar

RUN mkdir -p /opt/composer \
    && mv composer.phar /usr/local/bin/composer \
    && chmod 777 /usr/local/bin/composer

RUN apk --no-cache --update add \
    nano \
    iputils
    
# Configure xdebug
#RUN echo 'zend_extension="/usr/lib/php7/modules/xdebug.so"' >> /etc/php7/php.ini \
#    && echo "xdebug.remote_enable=on" >> /etc/php7/php.ini \
#    && echo "xdebug.remote_autostart=off" >> /etc/php7/php.ini \
#    && echo "xdebug.remote_connect_back=0" >> /etc/php7/php.ini \
#    && echo "xdebug.remote_port=9001" >> /etc/php7/php.ini \
#    && echo "xdebug.remote_handler=dbgp" >> /etc/php7/php.ini \
#    && echo "xdebug.remote_host=192.168.65.1" >> /etc/php7/php.ini
#     (Only for MAC users) Fill IP address from:
    # cat /Users/gtakacs/Library/Containers/com.docker.docker/Data/database/com.docker.driver.amd64-linux/slirp/host
    # Source topic on Docker forums: https://forums.docker.com/t/ip-address-for-xdebug/10460/22

# Copy Supervisor config file
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN adduser -s /sbin/nologin -D -G www-data www-data
RUN mkdir /run/apache2
RUN chown -R www-data:www-data /run/apache2/

# Copy Apache2 config
COPY apache2/httpd.conf /etc/apache2/httpd.conf

# Make run file executable
RUN chmod a+x /run.sh

RUN chmod a+rw /var/log/apache2

#RUN apk --no-cache --update add icu icu-libs icu-dev
#RUN docker-php-ext-install intl

EXPOSE 80 443 25
CMD ["/run.sh"]
WORKDIR /var/www/web

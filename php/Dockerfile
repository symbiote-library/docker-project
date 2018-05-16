FROM php:7.1-fpm

RUN usermod -u 1000 www-data


RUN apt-get update && apt-get install -y \
      libpng12-dev \
      libtidy-dev \
      libpng-dev \
      libjpeg62-turbo-dev \
      libfreetype6-dev \
      libmcrypt-dev \
      libicu-dev \
      ssmtp
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
      gd \
      mysqli \
      tidy \
      mbstring \
      mcrypt \
      opcache \
      pdo_mysql \
      intl \
      zip \
    && pecl install redis-4.0.2 \
    && pecl install xdebug \
    && docker-php-ext-enable \
      redis 

ENV TZ=Australia/Melbourne

RUN echo '[Date]\ndate.timezone = "Australia/Melbourne"' >> /usr/local/etc/php/conf.d/timezone.ini \
    && echo "mailhub=mailhog:1025\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf \
    && echo "sendmail_path = /usr/sbin/ssmtp -t" > /usr/local/etc/php/conf.d/sendmail.ini \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && mkdir -p /var/log/php \
    && chown www-data /var/log/php 

COPY php.ini /usr/local/etc/php/php.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
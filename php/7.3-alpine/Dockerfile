FROM php:7.3-fpm-alpine

RUN apk add --no-cache \
      bash \
      freetype-dev \
      gmp-dev \
      icu-dev \
      libxslt \
      libjpeg-turbo-dev \
      libmcrypt-dev \
      libpng-dev \
      libzip-dev \
      mysql-client \
      shadow \
      ssmtp

RUN usermod -u 1000 www-data

# Installing all Symbiote standard libraries and PHP extentions
RUN apk add --no-cache --virtual .build-deps \
      autoconf \
      build-base \
      g++ \
      libxslt-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
      gd \
      gmp \
      intl \
      mysqli \
      mbstring \
      opcache \
      pdo_mysql \
      sockets \
      soap \
      xsl \
      zip \
    && pecl install redis-4.0.1 \
    && pecl install mcrypt-1.0.3 \
    #&& pecl install xdebug
    && docker-php-ext-enable \
      redis \
      gmp \
    && apk del .build-deps

ENV TZ=Australia/Melbourne

RUN echo $'[Date]\ndate.timezone = "Australia/Melbourne"' >> /usr/local/etc/php/conf.d/timezone.ini \
    && echo "mailhub=mailhog:1025\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf \
    && echo "sendmail_path = /usr/sbin/ssmtp -t" > /usr/local/etc/php/conf.d/sendmail.ini \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && mkdir -p /var/log/php \
    && chown www-data /var/log/php

COPY php.ini /usr/local/etc/php/php.ini

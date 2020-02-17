FROM php:7.3-fpm

RUN usermod -u 1000 www-data

# See https://github.com/wodby/php/blob/master/7/Dockerfile
# https://github.com/wodby/drupal-php/issues/49
# for tideways installation

RUN apt-get update \
	&& apt-get install -my gnupg \
	&& apt-get install -y --allow-unauthenticated \
      default-mysql-client \
      libzip-dev \
      libtidy-dev \
      libpng-dev \
      libjpeg62-turbo-dev \
      libfreetype6-dev \
      libmcrypt-dev \
      libicu-dev \
      libxslt1-dev \
      libxslt1.1 \
      msmtp \
  && rm -rf /var/lib/apt/lists/* 

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
			sockets \
      gd \
      mysqli \
      tidy \
      mbstring \
      opcache \
      xsl \
      pdo_mysql \
      intl \
      zip \
      soap \
    && pecl install redis-4.0.2 \
    && pecl install mcrypt-1.0.2 \
    && pecl install xdebug \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable mcrypt 

# Tideways xhprof.
RUN xhprof_ext_ver="5.0.2"; \
    mkdir -p /usr/src/php/ext/tideways_xhprof; \
    xhprof_url="https://github.com/tideways/php-xhprof-extension/archive/v${xhprof_ext_ver}.tar.gz"; \
    curl -sL "${xhprof_url}" | tar xz --strip-components=1 -C /usr/src/php/ext/tideways_xhprof; \
    docker-php-ext-install tideways_xhprof

ENV TZ=Australia/Melbourne

RUN echo '[Date]\ndate.timezone = "Australia/Melbourne"' >> /usr/local/etc/php/conf.d/timezone.ini \
    && echo "account default\nhost mailhog\nport 1025\ntls off\nfrom noreply@symbiote.io" > /etc/msmtprc \
    && echo "sendmail_path = /usr/bin/msmtp -t" > /usr/local/etc/php/conf.d/sendmail.ini \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && mkdir -p /var/log/php \
    && chown www-data /var/log/php

COPY php.ini /usr/local/etc/php/php.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

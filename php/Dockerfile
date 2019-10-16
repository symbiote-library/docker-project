FROM php:7.1-fpm

RUN usermod -u 1000 www-data


RUN apt-get update \
	&& apt-get install -my gnupg \
  && curl --silent -o- https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg | apt-key add - \
	&&  apt-get install -y --allow-unauthenticated \
      mariadb-client \
      libtidy-dev \
      libpng-dev \
      libjpeg62-turbo-dev \
      libfreetype6-dev \
      libmcrypt-dev \
      libicu-dev \
      libxslt1-dev \
      libxslt1.1 \
      msmtp \
    #   tideways-daemon \
    #   tideways-php \
    #   tideways-cli \
    #   tideways-xhprof \
  && rm -rf /var/lib/apt/lists/*
#   && cp /usr/lib/tideways/tideways.ini /usr/local/etc/php/conf.d/

RUN cd /tmp && mkdir tideways && cd tideways && curl https://codeload.github.com/tideways/php-xhprof-extension/tar.gz/v4.1.2 > tideways.tgz \
    && tar zxf tideways.tgz && cd php-xhprof-extension-4.1.2 \
    && phpize && ./configure && make && make install


RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
			sockets \
      gd \
      mysqli \
      tidy \
      mbstring \
      mcrypt \
      opcache \
      xsl \
      pdo_mysql \
      intl \
      zip \
      soap \
    && pecl install redis-4.0.2 \
    && pecl install xdebug \
    && docker-php-ext-enable \
      redis

ENV TZ=Australia/Melbourne

RUN echo '[Date]\ndate.timezone = "Australia/Melbourne"' >> /usr/local/etc/php/conf.d/timezone.ini \
    && echo "host mailhog\nport 1025" > /etc/msmtprc \
    && echo "sendmail_path = /usr/sbin/msmtp -t" > /usr/local/etc/php/conf.d/sendmail.ini \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && mkdir -p /var/log/php \
    && chown www-data /var/log/php

COPY php.ini /usr/local/etc/php/php.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

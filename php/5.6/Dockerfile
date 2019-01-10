FROM php:5.6-fpm

RUN usermod -u 1000 www-data


RUN echo "deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main" > /etc/apt/sources.list.d/tideways.list \
	&& apt-get update \
	&& apt-get install -my gnupg \
  && curl --silent -o- https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg | apt-key add - \
  && apt-get update && apt-get install -y \
      mysql-client \
      libtidy-dev \
      libpng-dev \
      libjpeg62-turbo-dev \
      libfreetype6-dev \
      libmcrypt-dev \
      libicu-dev \
      libxslt1-dev \
      libxslt1.1 \
      ssmtp \
      tideways-daemon \
      tideways-php \
      tideways-cli \
  && rm -rf /var/lib/apt/lists/* \
  && cp /usr/lib/tideways/tideways.ini /usr/local/etc/php/conf.d/

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
			sockets \
      gd \
      mysqli \
      tidy \
      mbstring \
      mcrypt \
      opcache \
      pdo_mysql \
      xsl \
      intl \
      zip \
    && pecl install redis-4.0.2 \
    && pecl install xdebug-2.5.5 \
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

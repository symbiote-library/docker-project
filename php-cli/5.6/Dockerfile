FROM symbiote/php-fpm:5.6

RUN apt-get update && apt-get install -y \
    git

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME "/usr/local/composer" 
ENV COMPOSER_VERSION 1.8.0
ENV PATH "${COMPOSER_HOME}/vendor/bin:${PATH}"

RUN mkdir -p $COMPOSER_HOME \
       && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \ 
  && php -r "if (hash_file('sha384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \ 
  && php composer-setup.php --install-dir /usr/bin --filename=composer \ 
  && php -r "unlink('composer-setup.php');"

RUN composer global require phing/phing && chown -R www-data ${COMPOSER_HOME}

COPY sspak.phar /usr/local/bin/sspak

COPY memory.ini /usr/local/etc/php/conf.d/memory.ini

RUN mkdir -p /var/www/.ssh && \
    chmod 700 /var/www/.ssh && \
    ssh-keyscan github.com >> /var/www/.ssh/known_hosts && \
    ssh-keyscan bitbucket.org >> /var/www/.ssh/known_hosts && \
    ssh-keyscan gitlab.com >> /var/www/.ssh/known_hosts  && \
    ssh-keyscan gitlab.symbiote.com.au >> /var/www/.ssh/known_hosts  && \
    chown -R 1000:1000 /var/www/.ssh && \
    chmod 600 /var/www/.ssh/known_hosts

CMD ["/bin/bash"]

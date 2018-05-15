FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install -y \
    software-properties-common \
    apt-transport-https \
    build-essential \
    ca-certificates \
    nano \
    vim \
    git \
    curl \
    wget \
    sudo \
    zip \
    unzip \
    locales \
    openssl \
    apache2 \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite \
    && a2enmod headers \
    && a2enmod vhost_alias \
    && a2enmod expires \
    && a2enmod proxy \
    && a2enmod proxy_fcgi \
    && a2enmod ssl

RUN mkdir /opt/certs && \
    openssl genrsa -des3 -passout pass:x -out /opt/certs/server.pass.key 2048 && \
    openssl rsa -passin pass:x -in /opt/certs/server.pass.key -out /opt/certs/server.key && \
    rm /opt/certs/server.pass.key && \
    openssl req -new -key /opt/certs/server.key -out /opt/certs/server.csr -subj "/C=AU/ST=Victoria/L=Melbourne/O=Symbiote/OU=Devops/CN=*.symlocal" && \
    openssl x509 -req -days 365 -in /opt/certs/server.csr -signkey /opt/certs/server.key -out /opt/certs/server.crt

RUN rm /etc/apache2/sites-available/000-default.conf && rm /etc/apache2/sites-enabled/000-default.conf
ADD project.conf /etc/apache2/sites-available/100-default.conf
RUN ln -s /etc/apache2/sites-available/100-default.conf /etc/apache2/sites-enabled/100-default.conf

ADD apache-foreground /opt
RUN chmod +x /opt/apache-foreground

ENV VOLUME_PATH /var/www/html

CMD ["/opt/apache-foreground"]

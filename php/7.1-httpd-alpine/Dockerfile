FROM symbiote/php-fpm:7.1-alpine

RUN apk add --no-cache \
	apache2 \
	apache2-proxy \
	bash \
	supervisor

COPY ./supervisor.conf /etc/supervisor.conf

# Enable vhosts and fcgi proxy
RUN sed -ri \
			-e 's!^#(LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so)!\1!g' \
			-e 's!^#(LoadModule proxy_module modules/mod_proxy.so)!\1!g' \
			-e 's!^#ServerName.*!ServerName localhost!g' \
			-e '/LoadModule rewrite_module/s/^#//g' \
			-e '/LoadModule alias_module/s/^#//g' \
			-e '/LoadModule deflate_module/s/^#//g' \
			-e '/LoadModule expires_module/s/^#//g' \
			/etc/apache2/httpd.conf

COPY ./vhost.conf /etc/apache2/conf.d/httpd-vhosts.conf
RUN mkdir -p /run/apache2

EXPOSE 80
   
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
WORKDIR /var/www/html

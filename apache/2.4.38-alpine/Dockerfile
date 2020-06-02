FROM httpd:2.4.38-alpine

# Enable vhosts and fcgi proxy
RUN sed -ri \
			-e 's!^#(LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so)!\1!g' \
			-e 's!^#(LoadModule proxy_module modules/mod_proxy.so)!\1!g' \
			-e 's!^#(Include conf/extra/httpd-vhosts.conf)!\1!g' \
			-e '/LoadModule rewrite_module/s/^#//g' \
			-e '/LoadModule alias_module/s/^#//g' \
			-e '/LoadModule deflate_module/s/^#//g' \
			-e '/LoadModule expires_module/s/^#//g' \
			/usr/local/apache2/conf/httpd.conf

COPY ./vhost.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf

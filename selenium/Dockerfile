FROM selenium/standalone-chrome:2.53.1

USER root

RUN apt-get update  && apt-get install -y \
	inetutils-ping \
	knot-dnsutils \
	dnsmasq && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ADD dnsmasq.conf /etc/dnsmasq.conf

# gets copied by the init script. We need default resolution
# to begin with
ADD resolv.conf /tmp/resolv.conf

ADD entry_point.sh /opt/bin/entry_point.sh

ADD initialise.sh /tmp/init.sh

RUN chmod +x /tmp/init.sh && chmod +x /opt/bin/entry_point.sh

ENTRYPOINT ["/tmp/init.sh"]

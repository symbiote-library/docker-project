#!/bin/sh


if [ -n "${WEB_NAME-}" ]; then
	echo "Retrieving DNSMasq IP from ${WEB_NAME}"
	IP=$(kdig +short ${WEB_NAME})
	echo "Using IP of $IP"
else 
	echo "No WEB_NAME found, finding parent route"
	IP=$(ip route get 8.8.8.8 | awk '{ print $3 }')
fi

if [ -n "${IP-}" ]; then
	echo "Binding dnsmasq to $IP"
else 
	IP=127.0.0.11
fi

sed -i -r 's/(symlocal)\/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/symlocal\\/$IP/ /etc/dnsmasq.conf

cp /tmp/resolv.conf /etc/resolv.conf

service dnsmasq start

/opt/bin/entry_point.sh

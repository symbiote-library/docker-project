# Symbiote symbiote/selenium-chrome 

A container based on selenium-chrome that adds a dnsmasq instance to provide
name resolution for *.symlocal hostnames against either the host instance, or
against the configured webserver container. 

## Usage

**Build**

`docker build -t symbiote/selenium-chrome .`

**Run**

`docker run -it -e WEB_NAME='web56' symbiote/selenium-chrome /bin/sh`

**Compose**

```yml

  selenium:
    image: symbiote/selenium-chrome
    environment:
      - "WEB_NAME=web56"
    ports:
      - "4444:4444"
    volumes:
      - /dev/shm:/dev/shm

```

## Environment

The WEB_NAME env var can be set to indicate to the container the linked docker
container that dnsmasq should point to for *.symlocal hostnames. 
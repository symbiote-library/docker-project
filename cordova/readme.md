# Symbiote Cordova

Docker container for running command line cordova. 

Built on work created by https://github.com/beevelop/docker-cordova

This dockerfile is a condensation of those preliminaries, but with
later versions included. 

Run with the following volume mounts to retain cached data. 

```
docker run -it \
	-u `id -u`:`id -g` \
	-v ~/docker/cordova/config:/home/cordova/.config \
        -v ~/docker/cordova/android:/home/cordova/.android \
        -v ~/docker/cordova/gradle:/home/cordova/.gradle \
        -v ~/docker/cordova/npm:/home/cordova/.npm \
        -v ~/docker/cordova/oracle_jre_usage:/home/cordova/.oracle_jre_usage \
	-v $(pwd):/tmp/work \
	--privileged -v /dev/bus/usb:/dev/bus/usb \
	-w /tmp/work \
	-p 8000:8000 \
	--name cordovabash \
	--rm symbiote/cordova
```
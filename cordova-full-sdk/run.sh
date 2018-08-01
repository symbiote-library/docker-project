docker run -it \
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
	--rm symbiote/cordova-full-sdk


    # -u `id -u`:`id -g` \
	
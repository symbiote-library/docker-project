FROM ubuntu:16.04

# Java things
RUN buildDeps='software-properties-common'; \
    set -x && \
    apt-get update && apt-get install -y $buildDeps --no-install-recommends && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update -y && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get install -y oracle-java8-set-default && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get autoremove -y && apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# ANDROID THINGS
# Hints taken from https://stackoverflow.com/questions/30301198/android-sdk-tools-install-in-docker-fails
# Find the download link on https://developer.android.com/studio/ under Command line tools only
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    ANDROID_BUILD_TOOLS_VERSION=27.0.0 \
    ANDROID_APIS="android-23,android-24,android-25,android-26,android-27,android-28" \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_HOME="/opt/android"

# android-10,android-15,android-16,android-17,android-18,android-19,android-20,android-21,android-22,

ENV PATH $PATH:$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

WORKDIR /opt

RUN dpkg --add-architecture i386 && \
    apt-get -qq update && \
    apt-get -qq install -y wget curl maven ant gradle libncurses5:i386 libstdc++6:i386 zlib1g:i386 && \
    mkdir android && cd android && \
    wget -O sdk.zip ${ANDROID_SDK_URL} && \
    unzip sdk.zip && rm sdk.zip && \
    yes | android update sdk -a -u -t platform-tools,${ANDROID_APIS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean


# NODE parts
ENV NODEJS_VERSION=8.11.2 \
    PATH=$PATH:/opt/node/bin

WORKDIR "/opt/node"

RUN apt-get update && apt-get install -y curl git ca-certificates --no-install-recommends && \
    curl -sL https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz | tar xz --strip-components=1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean


# CORDOVA parts
ENV CORDOVA_VERSION 8.0.0

WORKDIR "/tmp"

RUN npm i -g --unsafe-perm cordova@${CORDOVA_VERSION} && npm install -g cordova-simulate

# ENV ANDROID_PLATFORM_TOOLS_URL="https://dl.google.com/android/repository/platform-tools_r28.0.0-linux.zip"

# WORKDIR /opt

# RUN wget -O plaform-tools.zip ${ANDROID_PLATFORM_TOOLS_URL} && \
#     unzip plaform-tools.zip && rm plaform-tools.zip

RUN mkdir -p /home/cordova && mkdir -p /etc/sudoers.d && \
    echo "cordova:x:1000:1000:Cordova,,,:/home/cordova:/bin/bash" >> /etc/passwd && \
    echo "cordova:x:1000:" >> /etc/group && \
    echo "cordova ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cordova && \
    chmod 0440 /etc/sudoers.d/cordova && \
    chown cordova:cordova -R /home/cordova

USER cordova
ENV HOME /home/cordova

# RUN groupadd --gid 1000 cordova \
#   && useradd --uid 1000 --gid cordova --shell /bin/bash --create-home cordova

COPY entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT [ "/opt/entrypoint.sh" ]
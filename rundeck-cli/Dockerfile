FROM openjdk:8-jdk
RUN mkdir /tmp/rd && curl -sL https://github.com/rundeck/rundeck-cli/archive/feature/repository-commands.zip > /tmp/rd/rd.zip
RUN cd /tmp/rd/ \
    && unzip rd.zip \
    && cd rundeck-cli-feature-repository-commands \
    && ./gradlew build \
    && ls build/distributions/ \
    && dpkg -i build/distributions/*.deb \
    && rm -rf /tmp/rd
ENV RD_URL http://rundeck:4440
ENV RD_BYPASS_URL http://127.0.0.1:4440
ENV RD_USER admin
ENV RD_PASSWORD admin
ENV RD_ENABLE_PLUGINS true
WORKDIR /root
ENTRYPOINT ["/usr/bin/rd"]

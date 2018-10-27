FROM openjdk:8-jdk
COPY --from=gradle:jdk8 /opt/gradle /opt/gradle
RUN ln -s /opt/gradle/bin/gradle /usr/bin/gradle
ARG COMMIT
RUN mkdir /root/rd && curl -sL https://github.com/rundeck/rundeck-cli/archive/${COMMIT}.zip > /root/rd/rd.zip
RUN cd /root/rd/ \
    && unzip rd.zip \
    && cd rundeck-cli-${COMMIT} \
    && gradle --no-daemon :distZip
RUN unzip -d /root/tools /root/rd/rundeck-cli-${COMMIT}/build/distributions/rd-0.1.0-SNAPSHOT.zip \
    && rm -rf /root/rd

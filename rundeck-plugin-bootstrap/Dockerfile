FROM openjdk:8-jdk
COPY --from=gradle:jdk8 /opt/gradle /opt/gradle
RUN ln -s /opt/gradle/bin/gradle /usr/bin/gradle
ARG COMMIT
RUN mkdir /root/plugin-bootstrap && curl -sL https://github.com/rundeck/plugin-bootstrap/archive/${COMMIT}.zip > /root/plugin-bootstrap/plugin-bootstrap.zip
RUN cd /root/plugin-bootstrap \
    && unzip plugin-bootstrap.zip \
    && rm plugin-bootstrap.zip \
    && cd plugin-bootstrap-${COMMIT} \
    && ./gradlew distZip
RUN unzip -d /root/tools/ /root/plugin-bootstrap/plugin-bootstrap-${COMMIT}/build/distributions/rundeck-plugin-bootstrap-0.1.0-SNAPSHOT.zip \
    && rm -rf /root/plugin-bootstrap

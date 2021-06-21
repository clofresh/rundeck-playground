FROM openjdk:8-jdk
COPY --from=gradle:jdk8 /opt/gradle /opt/gradle
RUN ln -s /opt/gradle/bin/gradle /usr/bin/gradle
ARG VERSION
RUN mkdir /root/plugin-bootstrap && wget https://github.com/rundeck/plugin-bootstrap/releases/download/${VERSION}/rundeck-plugin-bootstrap-${VERSION}.zip -P /root/plugin-bootstrap
RUN cd /root/plugin-bootstrap \
    && unzip rundeck-plugin-bootstrap-${VERSION}.zip \
    && mv rundeck-plugin-bootstrap-${VERSION}/bin/rundeck-plugin-bootstrap /usr/local/openjdk-8/bin

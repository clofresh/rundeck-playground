FROM openjdk:8-jre
RUN curl -sL https://github.com/rundeck/rundeck-cli/releases/download/v1.1.0-alpha/rundeck-cli_1.1.0.SNAPSHOT-1_all.deb > /rundeck-cli.deb
RUN dpkg -i /rundeck-cli.deb && rm /rundeck-cli.deb
ENV RD_URL http://rundeck:4440
ENV RD_BYPASS_URL http://127.0.0.1:4440
ENV RD_USER admin
ENV RD_PASSWORD admin
WORKDIR /root
ENTRYPOINT ["/usr/bin/rd"]

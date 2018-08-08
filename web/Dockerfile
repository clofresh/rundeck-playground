FROM rd-example-ssh

RUN apt-get update -qq && apt-get install -qqy python3 postgresql-client python3-pip
RUN pip3 install pyyaml pyaml
COPY web.py /usr/share/
COPY web.yaml /etc/
RUN chmod 644 /etc/web.yaml
ENV APP_PORT 8080
EXPOSE 8080

COPY web.simple-init.sh /etc/simple-init.d/web

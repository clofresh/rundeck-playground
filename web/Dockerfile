FROM playground-ssh

RUN apt-get update -qq && apt-get install -qqy postgresql-client
RUN pip3 install pyyaml pyaml psycopg2-binary
COPY web.py /usr/share/
COPY web.yaml /etc/
RUN chmod 644 /etc/web.yaml
ENV APP_PORT 8080
EXPOSE 8080

COPY web.simple-init.sh /etc/simple-init.d/web

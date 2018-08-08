FROM rd-example-ssh

RUN apt-get update -qq && apt-get install -qqy python3 postgresql-client python-psycopg2

COPY web.py /usr/bin
RUN chmod 755 /usr/bin/web.py
ENV APP_PORT 8080
EXPOSE 8080

COPY web.simple-init.sh /etc/simple-init.d/web

FROM rd-example-ssh

RUN apt-get update -qq && apt-get install -qqy postgresql-client npm
RUN npm -g install express
COPY web.js /usr/bin/web
RUN chmod 755 /usr/bin/web
ENV APP_PORT 8080
EXPOSE 8080
ENV NODE_PATH /usr/local/lib/node_modules
COPY web.simple-init.sh /etc/simple-init.d/web

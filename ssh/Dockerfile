FROM python:3-stretch

RUN apt-get update -qq && apt-get install -qqy openssh-server vim-nox
RUN mkdir /var/run/sshd /root/.ssh && chmod 0600 /root/.ssh
COPY authorized_keys /root/.ssh/

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22
COPY simple-init.sh /usr/bin/
RUN chmod 755 /usr/bin/simple-init.sh

RUN mkdir -p /etc/simple-init.d
COPY ssh.simple-init.sh /etc/simple-init.d/ssh

CMD ["/usr/bin/simple-init.sh"]

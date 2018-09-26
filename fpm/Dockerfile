# Pull base image.
FROM playground-ssh

# Install aws cli
RUN pip install awscli awscli-plugin-endpoint && mkdir /root/.aws

# Install FPM.
RUN apt-get update -q && apt-get install -yy ruby-dev && gem install fpm

# Point to our fakes3 endpoint
COPY aws.ini /root/.aws/config

# Define working directory.
WORKDIR /data

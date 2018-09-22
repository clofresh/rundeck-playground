# Pull base image.
FROM playground-ssh

# Install aws cli
RUN pip install awscli

# Install FPM.
RUN apt-get update -q && apt-get install -yy ruby-dev && gem install fpm

# Define working directory.
WORKDIR /data

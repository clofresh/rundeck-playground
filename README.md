# Rundeck playground

## Overview

This is a Docker environment to help you develop and test Rundeck plugins in a distributed system.

Note that while all these services are in Docker containers, Rundeck doesn't need Docker to run, nor do you need to have a dockerized application to benefit from it. Docker is only used here so that you can play with a distributed system on your local workstation.

See the [Rundeck docs](http://rundeck.org/docs/administration/install/index.html) for how to install Rundeck in a real world setting.

# Prerequisites

* [docker](https://docs.docker.com/install/#supported-platforms)
* [docker compose](https://docs.docker.com/compose/install/)
* make
* bash

## Usage

To start up the environment:

```
make
```

This will run docker-compose to build all the images and start the containers in the foreground. Leave this process running so you can see the logs from all the containers.

To configure the Rundeck server with the example project, jobs, keys and hello world plugin, run:

```
make rd-config
```

To kick off the hello world job:

```
make rd-run-job
```

You should see something like this:

```
 Found matching job: c8c66849-a66a-4714-bdc1-5b6f09dbd151 Hello Test Job
# Execution started: [97] c8c66849-a66a-4714-bdc1-5b6f09dbd151 /Hello Test Job <http://127.0.0.1:4440/project/hello-project/execution/show/97>
[727700d20fcf] Hello bash from Hello Test Job
[ace491b72364] Hello bash from Hello Test Job
```

You might have to wait a few seconds for the Rundeck server to finish booting up before running rd-run-job.

You can also interact with the Rundeck server using the `rd` command line tool. Since both the server and the client are dockerized, you'll need to run it with a special command:

```
docker run \
    --network rundeck-playground_default \
    --mount type=bind,source="$(pwd)",target=/root \
    -e RD_PROJECT=hello-project \
    playground-rundeck-cli \
    run -f --job 'HelloWorld'
```

To avoid all that typing, you can create an alias:

```
alias rd='docker run --network rundeck-playground_default --mount type=bind,source="$(pwd)",target=/root -e RD_PROJECT=hello-project playground-rundeck-cli '

rd run -f --job 'HelloWorld'
```

## Directory structure

 This repo is docker-compose project with several containers, each with a corresponding directory:

* rundeck - the Rundeck server
* rundeck-cli - the rd Rundeck command line client
* web - a simple web app that would represent your company's app. There are 2 instance of them in the docker-compose environment. This container also runs an ssh daemon to allow for rundeck to ssh into it and run commands
* database - a postgres database that the web app depends on
* loadbalancer - the public facing web proxy that load balances between the web instances

Other directories that aren't containers:

* rundeck-project - Various Rundeck server configuration
* rundeck-plugins - Sample Rundeck plugins. Any new directories will get deployed as Rundeck plugins
* docs - A guide on how build a Rundeck plugin that's used here

The containers are run by docker-compose as specified by the `docker-compose.yml` file. See the [docker-compose docs](https://docs.docker.com/compose/compose-file/) for reference.

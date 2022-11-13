# Moringa environment

This sets up the moringa environment on docker. It is expected that the student
has generated ssh keys as mentioned on canvas LMS. The docker image with the tools
shares the same ssh keys as the host system - This simple scheme works quite effortlessly
in a classroom or test environment but is not recommmended in a production environment.


## Setting up the environment

The tools assume that the host system is ubuntu or debian based. Docker should also be installed.

To install docker using apt:

`sudo apt install docker`

After docker has completed successfully run:

`DOCKER_BUILDKIT=1 docker build -t moringa-environment . && docker run -it --rm -v ~/.ssh:/root/.ssh:ro moringa-environment`

Building the image may take substantial time the first time the command is run, however use of docker build caches will ensure
instanteneous  runtimes subsequently.

## TODO

Change user from 'root' to lower priviledged user 'moringastudent'
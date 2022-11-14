FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

#User defined variables
ARG NODE_VERSION='16.13.0'
ARG RUBY_VERSION='2.7.4'
ARG GH_NAME='Alois Mbutura'
ARG GH_EMAIL='alois.mbutura@student.moringaschool.com'

ENV user 'moringastudent'
ENV RVM_DIR /home/${user}/.rvm
ENV NVM_DIR /home/${user}/.nvm

#Update package list and install sudo
RUN apt-get update && apt-get -y install sudo

#Create user moringastudent and enable use of /bin/bash which can source
#the rvm scripts
RUN useradd -m -d /home/${user} -s /bin/bash ${user} && \
    chown -R ${user} /home/${user} && \
    adduser ${user} sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ${user}
WORKDIR /home/${user}

#Install prerequisites to node and ruby installation such as curl and other apt commands
RUN sudo apt-get update && sudo apt-get install -y \
    apt-utils \
    curl \
    software-properties-common

# Get rvm install script from github and pipe to bash interpreter binary for execution. Change install 
# path to non-priviledged folder in user's home diretory 
RUN curl -sSL https://get.rvm.io | bash -s -- --path ${RVM_DIR}

# Get nvm install script from github and pipe to bash interpreter binary for execution
RUN curl -o- curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

#Install nodejs NODE_VERSION using nvm
RUN /bin/bash -l -c "source $NVM_DIR/nvm.sh && nvm install ${NODE_VERSION}"

#Set nvm alias default to nodejs NODE_VERSION
RUN /bin/bash -l -c "source $NVM_DIR/nvm.sh && nvm alias default v${NODE_VERSION}"

#install ruby version RUBY_VERSION
RUN /bin/bash -l -c "source /home/${user}/.rvm/scripts/rvm && rvm install $RUBY_VERSION --default"

# #Install ruby gems such as bundler and pry
RUN /bin/bash -l -c "source /home/${user}/.rvm/scripts/rvm && gem update --system && gem install bundler && gem install pry && gem list | wc -l"

#enable .bashrc when user moringastudent logs into bash shell
RUN echo "[ -s /home/${user}/.rvm/scripts/rvm ] && source /home/${user}/.rvm/scripts/rvm" >> /home/${user}/.bashrc

# Add git ppa to apt-list and install latest
RUN sudo add-apt-repository ppa:git-core/ppa && sudo apt update && sudo apt install -y git

#Confirm node, npm and ruby versions installed
RUN /bin/bash -l -c "source $NVM_DIR/nvm.sh && node --version"
RUN /bin/bash -l -c "source $NVM_DIR/nvm.sh && npm --version"
RUN /bin/bash -l -c "source /home/${user}/.rvm/scripts/rvm && ruby --version"
RUN git --version

RUN git config --global color.ui true \
 && git config --global user.name "$GH_NAME" \
 && git config --global user.email "$GH_EMAIL" \
 && git config --global init.defaultBranch main

#Create directory .ssh and preceding parent directories'
RUN mkdir -p /home/moringastudent/.ssh

#Disable stricthostchecking in ssh config as the ssh key owner will not match with the docker host
RUN echo "Host *\n\tStrictHostKeyChecking no\n" >> /home/moringastudent/.ssh/config
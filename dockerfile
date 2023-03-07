FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-20.04

ARG DEBIAN_FRONTEND=noninteractive

#User defined variables
ARG NODE_VERSION='16.13.0'
ARG RUBY_VERSION='2.7.4'
ARG GH_NAME='Alois Mbutura'
ARG GH_EMAIL='alois.mbutura@student.moringaschool.com'
ARG ssh_prv_key
ARG ssh_pub_key

ENV user 'moringastudent'
ENV RVM_DIR /home/${user}/.rvm
ENV NVM_DIR /home/${user}/.nvm

#Update package list and install sudo
RUN apt-get update && apt-get -y install sudo ssh

#Create user moringastudent and enable use of /bin/bash which can source
#the rvm scripts
RUN useradd -m -d /home/${user} -s /bin/bash ${user} && \
    chown -R ${user} /home/${user} && \
    adduser ${user} sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ${user}
WORKDIR /home/${user}

# Authorize SSH Host
RUN mkdir -p /home/${user}/.ssh && \
    chmod 0700 /home/${user}/.ssh && \
    ssh-keyscan github.com > /home/${user}/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$ssh_prv_key" > /home/${user}/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /home/${user}/.ssh/id_rsa.pub && \
    chmod 600 /home/${user}/.ssh/id_rsa && \
    chmod 600 /home/${user}/.ssh/id_rsa.pub

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

# #Install ruby gems such as bundler, rspec rspand pry
RUN /bin/bash -l -c "source /home/${user}/.rvm/scripts/rvm && gem update --system && gem install bundler && gem install pry && gem install rspec && gem list | wc -l"

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

#Install node http-server to serve requests from docker image created from this file
RUN /bin/bash -l -c "source $NVM_DIR/nvm.sh && npm install --global http-server json-server create-react-app"

#Install sqlite 3 and GNU nano
RUN sudo apt install sqlite3 nano

#App test and json.db port
EXPOSE 5050 3000 5173 4173 9292

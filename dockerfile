FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

#User defined variables
ENV NODE_VERSION=16.13.0
ENV RUBY_VERSION=2.7.4
ENV GH_NAME = 'Alois Mbutura'
ENV GH_EMAIL = 'alois.mbutura@student.moringaschool.com'

#Install prerequisites to node and ruby installation such as curl and other apt commands
RUN apt-get update && apt-get install -y \
    apt-utils \
    curl \
    software-properties-common

# Add rael-gc/rvm ppa to apt-list and perform non-interactive install    
RUN apt-add-repository -y ppa:rael-gc/rvm && apt-get install -y rvm

# Get nvm install script from github and pipe to bash interpreter binary for execution
RUN curl -o- curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

#Set NVM to ${HOME}/.nvm . In docker $HOME defaults to /root
ENV NVM_DIR=/root/.nvm

#Install nodejs NODE_VERSION using nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}


#Set nvm alias default to nodejs NODE_VERSION
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}

#Add rvm npm rvm to PATH
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:$GEM_HOME/bin:/usr/share/rvm/bin:${PATH}"

#install ruby version RUBY_VERSION
RUN rvm install $RUBY_VERSION --default

#Install ruby gems such as bundler and pry
RUN rvm all do gem update --system && rvm all do gem install bundler && rvm all do gem install pry && rvm all do gem list | wc -l

#Add bash startup instructions so as to be able to call ruby scripts without rvm all do X because the scripts disallow sourcing into sh shells.
#Docker natively uses sh shells hence the need to do rvm all do X(gem, ruby)
RUN echo "PATH=$GEM_HOME/bin:/usr/share/rvm/bin:$PATH" >> $HOME/.bashrc
RUN echo "[ -s /usr/share/rvm/scripts/rvm ] && source /usr/share/rvm/scripts/rvm" >> $HOME/.bashrc

# Add git ppa to apt-list and install latest
RUN add-apt-repository ppa:git-core/ppa && apt update && apt install -y git

#Confirm node, npm and ruby versions installed
RUN node --version
RUN npm --version
RUN rvm all do ruby --version
RUN git --version

RUN git config --global color.ui true \
 && git config --global user.name "$GH_NAME" \
 && git config --global user.email "$GH_EMAIL" \
 && git config --global init.defaultBranch main

#Add user 'user'
RUN useradd -m moringastudent

#Create directory .ssh and preceding parent directories'
#RUN mkdir -p /home/moringastudent/.ssh
RUN mkdir -p /root/.ssh

#Set ownership of the ssh folder from root to moringastudent
#RUN chown -R moringastudent:moringastudent /home/moringastudent/.ssh

#Disable stricthostchecking in ssh config as the ssh key owner will not match with the docker host
#RUN echo "Host *.trabe.io\n\tStrictHostKeyChecking no\n" >> /home/moringastudent/.ssh/config
RUN echo "Host *.trabe.io\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

#Change user to moringastudent
#USER moringastudent


FROM ubuntu:14.04
MAINTAINER James Carscadden <james@carscadden.org>

#env variables
ENV VSO_CONFIG_USERNAME=""
ENV VSO_CONFIG_PASSWORD=""
ENV VSO_CONFIG_URL=""
ENV VSO_CONFIG_AGENTNAME=$HOSTNAME
ENV VSO_CONFIG_AGENTPOOL=default
ENV VSO_CONFIG_SERVICE_USERNAME=vsoservice
ENV VSO_CONFIG_SERVICE_PASSWORD=vsoservice

# Prepare for software installs
RUN apt-get update
RUN apt-get install curl -y

# install the prerequisite patches here so that rvm will install under non-root account. 
RUN apt-get install -y patch gawk g++ gcc make libc6-dev patch libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev unzip

# Add more up to date Node sources
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -

# INSTALL Expect
RUN apt-get install expect -y

# INSTALL GIT
RUN apt-get install git -y

# INSTALL postgres
RUN echo "deb https://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/postgres.list
RUN curl -sL https://postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install postgresql-9.5 postgresql-server-dev-9.5 -y

# INSTALL NODE JS
RUN apt-get install nodejs -y

# INSTALL bower
RUN npm install bower -g

# Create a service user 
RUN echo "${VSO_CONFIG_SERVICE_USERNAME}\n${VSO_CONFIG_SERVICE_PASSWORD}\n\n\n\n\n\n\n" | adduser ${VSO_CONFIG_SERVICE_USERNAME}

# Install the VSO Agent
USER ${VSO_CONFIG_SERVICE_USERNAME}

WORKDIR /home/${VSO_CONFIG_SERVICE_USERNAME}
RUN mkdir vsoagent
WORKDIR /home/${VSO_CONFIG_SERVICE_USERNAME}/vsoagent
RUN curl -skSL http://aka.ms/xplatagent | bash

# INSTALL RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN /bin/bash -l -c "curl -sSL https://get.rvm.io | bash -s stable"

# GET Ruby
RUN /bin/bash -l -c "rvm install 2.2"
RUN /bin/bash -l -c "rvm --default use 2.2"

# GET Bundler
RUN /bin/bash -l -c "gem install bundler"

COPY ConfigureAgent.expect ConfigureAgent.expect

# Run the agent
USER ${VSO_CONFIG_SERVICE_USERNAME}
CMD /bin/bash -l -c "cd ~/vsoagent;expect ConfigureAgent.expect"

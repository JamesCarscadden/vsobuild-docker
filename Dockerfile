FROM node
MAINTAINER James Carscadden <james@carscadden.org>

#env variables
ENV VSO_CONFIG_USERNAME=""
ENV VSO_CONFIG_PASSWORD=""
ENV VSO_CONFIG_URL=""
ENV VSO_CONFIG_AGENTNAME=$HOSTNAME
ENV VSO_CONFIG_AGENTPOOL=default
ENV VSO_CONFIG_SERVICE_USERNAME=vsoservice
ENV VSO_CONFIG_SERVICE_PASSWORD=vsoservice

RUN apt-get update

# install the prerequisite patches here so that rvm will install under non-root account. 
RUN apt-get install -y curl patch gawk g++ gcc make libc6-dev patch libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev

# Add more up to date Node sources
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -

# INSTALL Expect
RUN apt-get install expect -y

# INSTALL GIT
RUN apt-get install git -y

# INSTALL NODE JS
RUN apt-get install nodejs -y

# INSTALL VSO Agent
RUN npm install vsoagent-installer bower -g

#CREATE SOME dirs
RUN mkdir opt/buildagent
RUN mkdir opt/buildagent/_work

#COPY expect file
WORKDIR /opt/buildagent
COPY ConfigureAgent.expect ConfigureAgent.expect

#  Install the agent
WORKDIR /opt/buildagent
RUN vsoagent-installer
WORKDIR /opt/buildagent/agent

#  Create a service user 
RUN echo "${VSO_CONFIG_SERVICE_USERNAME}\n${VSO_CONFIG_SERVICE_PASSWORD}\n\n\n\n\n\n\n" | adduser ${VSO_CONFIG_SERVICE_USERNAME}

# Adjust permissions for agent
RUN chown -R ${VSO_CONFIG_SERVICE_USERNAME} /opt/buildagent


USER ${VSO_CONFIG_SERVICE_USERNAME}

# INSTALL RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN /bin/bash -l -c "curl -sSL https://get.rvm.io | bash -s stable"

# GET Ruby
RUN /bin/bash -l -c "rvm install 2.2"
RUN /bin/bash -l -c "rvm --default use 2.2"

# GET Bundler
RUN /bin/bash -l -c "gem install bundler"

# Run the agent
USER ${VSO_CONFIG_SERVICE_USERNAME}
CMD /bin/bash -l -c "cd /opt/buildagent;expect ConfigureAgent.expect"

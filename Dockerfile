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

# Get Curl - it's needed for Node below and RVM
RUN apt-get install curl -y

# Add more up to date Node sources
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -

# INSTALL Expect
RUN apt-get install expect -y

# INSTALL GIT
RUN apt-get install git -y

# INSTALL NODE JS
RUN apt-get install nodejs -y

# INSTALL VSO Agent
RUN npm install vsoagent-installer -g

#CREATE SOME dirs
RUN mkdir opt/buildagent
RUN mkdir opt/buildagent/_work

#COPY expect file
WORKDIR /opt/buildagent
COPY ConfigureAgent.expect ConfigureAgent.expect

#  Create a service user 
RUN echo "${VSO_CONFIG_SERVICE_USERNAME}\n${VSO_CONFIG_SERVICE_PASSWORD}\n\n\n\n\n\n\n" | adduser ${VSO_CONFIG_SERVICE_USERNAME}
RUN su ${VSO_CONFIG_SERVICE_USERNAME}

#  Install the agent
WORKDIR /opt/buildagent
RUN vsoagent-installer
WORKDIR /opt/buildagent/agent
RUN chown -R ${VSO_CONFIG_SERVICE_USERNAME} /opt/buildagent

WORKDIR /opt/buildagent

USER ${VSO_CONFIG_SERVICE_USERNAME}
CMD expect ConfigureAgent.expect

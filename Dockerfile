FROM jamescarscadden/vsts-deploy-rails
MAINTAINER James Carscadden <james@carscadden.org>

#env variables
ENV VSTS_CONFIG_USERNAME=""
ENV VSTS_CONFIG_PASSWORD=""
ENV VSTS_CONFIG_URL=""
ENV VSTS_CONFIG_AGENTNAME=$HOSTNAME
ENV VSTS_CONFIG_AGENTPOOL=default
ENV VSTS_CONFIG_SERVICE_USERNAME=vstsservice
ENV VSTS_CONFIG_SERVICE_PASSWORD=vstsservice

# Create a service user
RUN echo "${VSTS_CONFIG_SERVICE_USERNAME}\n${VSTS_CONFIG_SERVICE_PASSWORD}\n\n\n\n\n\n\n" | adduser ${VSTS_CONFIG_SERVICE_USERNAME}

# Install the VSO Agent
USER ${VSTS_CONFIG_SERVICE_USERNAME}

WORKDIR /home/${VSTS_CONFIG_SERVICE_USERNAME}
RUN mkdir vstsagent
WORKDIR /home/${VSTS_CONFIG_SERVICE_USERNAME}/vstsagent
RUN curl -skSL http://aka.ms/xplatagent | bash

# INSTALL RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN /bin/bash -l -c "curl -sSL https://get.rvm.io | bash -s stable"

# GET Ruby
RUN /bin/bash -l -c "rvm install 2.3"
RUN /bin/bash -l -c "rvm --default use 2.3"

# GET Bundler
RUN /bin/bash -l -c "gem install bundler"

COPY ConfigureAgent.expect ConfigureAgent.expect

# Run the agent
USER ${VSTS_CONFIG_SERVICE_USERNAME}
CMD /bin/bash -l -c "cd ~/vstsagent;expect ConfigureAgent.expect"

# vsts-agent-rails

This is a docker container with a Visual Studio Team System build agent and tools suitable for use as a Ruby on Rails and Postgres continuous integration server.

To Use

```
docker pull jamescarscadden/vsts-agent-rails
docker run -t --name vstsagent --link railsPostgres:postgres -e VSTS_CONFIG_USERNAME=<username> -e VSTS_CONFIG_PASSWORD=<password> -e VSTS_CONFIG_URL=<url for vsts> -e VSTS_CONFIG_AGENTNAME=<agent name> -d jamescarscadden/vsts-agent-rails
```

Fill in the parameters above with values for your own project.
Note the '--link' argument. This docker is built with only Postgres development libraries, not the entire postgres server. If you wish to deploy and test a database, an additional docker container should be deployed with the postgres database using the following:

```
docker run --name railsPostgres -e POSTGRES_PASSWORD=<db password> -d postgres
```

This container was built based on the blog post from the Road to ALM blog

[Running a Visual Studio Build vNext agent in a Docker container](http://roadtoalm.com/2015/08/07/running-a-visual-studio-build-vnext-agent-in-a-docker-container/)

and

[Running a VS Team Services (VSO) Build Agent in a Windows Docker Container](http://roadtoalm.com/2016/02/15/running-a-vs-team-services-vso-build-agent-in-a-windows-docker-container)

as well as the associated code from [renevanosnabrugge/vsobuild-docker](https://github.com/renevanosnabrugge/vsobuild-docker)

FROM microsoft/aspnet:1.0.0-rc1-update1-coreclr

RUN apt-get update && apt-get install -y git curl
RUN git clone https://github.com/aspnet/EntityFramework.Docs

WORKDIR "EntityFramework.Docs/docs/getting-started/aspnet5/sample/src/EFGetStarted.AspNet5.ExistingDb"
RUN [ "dnu", "restore", "--runtime", "ubuntu.14.04-x64" ]

EXPOSE 5000
ENTRYPOINT ["dnx", "web"]
#ENTRYPOINT ["dnx", "-p", "project.json", "web"]

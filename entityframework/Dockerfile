FROM microsoft/aspnet:1.0.0-rc1-update1-coreclr

RUN apt-get update && apt-get install -y git curl
RUN git clone https://github.com/aspnet/EntityFramework.Docs

WORKDIR "EntityFramework.Docs/docs/getting-started/aspnet5/sample/src/EFGetStarted.AspNet5.ExistingDb"
RUN sed -i -e "s/Server=\(localdb\)\\mssqllocaldb;Database=Blogging;Trusted_Connection=True;/Server=192.168.0.56;Database=test;User Id=testUser;Password=P@ssw0rd;/g" Startup.cs

RUN [ "dnu", "restore", "--runtime", "ubuntu.14.04-x64" ]

EXPOSE 5000
#ENTRYPOINT ["dnx", "web"]

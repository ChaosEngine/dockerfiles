FROM debian:latest
MAINTAINER Chaos Engine <haos.engine@gmail.com>

#custom trial (expiring!) key
ENV MEMSQLKEY f9b7963eb1c24eadbe24edd3fe979cd2

#dependency include g++, mysql-client officially. Unofficialy it needs procps (coz of free) and libgssapi-krb5-2
#install *.deb and if successfull, remove downloaded *.deb
RUN apt-get -y update && apt-get -y install \
	wget \
	procps \
	g++ \
	libgssapi-krb5-2 \
	mysql-client \
	&& wget -q "http://download.memsql.com/$MEMSQLKEY/memsql-3.2.x86_64.deb" \
	&& apt-get purge -y --auto-remove wget \
	&& dpkg -i memsql-3.2.x86_64.deb \
	&& rm -f memsql-3.2.x86_64.deb

#using mysql listening port
EXPOSE 3306

CMD /var/lib/memsql/memsqld -u memsql

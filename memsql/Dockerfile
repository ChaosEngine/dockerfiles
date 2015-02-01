FROM debian:latest
MAINTANER Chaos Engine <haos.engine@gmail.com>

#custom trial (expiring!) key
ENV MEMSQLKEY cb7eec38ab4a44579a97d2668e92f5b5

#dependency include g++, mysql-client officially. Unofficialy it needs procps (coz of free) and libgssapi-krb5-2
RUN apt-get -y update && apt-get -y install \
	curl \
	procps \
	g++ \
	libgssapi-krb5-2 \
	mysql-client \
	&& curl -SL "http://download.memsql.com/$MEMSQLKEY/memsql-3.2.x86_64.deb" -o memsql-3.2.x86_64.deb \
	&& apt-get purge -y --auto-remove curl

#install and if successfull, remove downloaded *.deb
RUN dpkg -i memsql-3.2.x86_64.deb \
	&& rm -f memsql-3.2.x86_64.deb

#using mysql listening port
EXPOSE 3306

CMD /var/lib/memsql/memsqld -u memsql

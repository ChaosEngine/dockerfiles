FROM debian:latest
MAINTANER Chaos Engine <haos.engine@gmail.com>

ENV MEMSQLKEY cb7eec38ab4a44579a97d2668e92f5b5

RUN apt-get -y update && apt-get -y install \
	curl \
	procps \
	g++ \
	libgssapi-krb5-2 \
	mysql-client \
	&& curl -SL "http://download.memsql.com/$MEMSQLKEY/memsql-3.2.x86_64.deb" -o memsql-3.2.x86_64.deb \
	&& apt-get purge -y --auto-remove curl

RUN dpkg -i memsql-3.2.x86_64.deb \
	&& chsh -s /bin/bash memsql
RUN	rm -f memsql-3.2.x86_64.deb

EXPOSE 3306

#CMD su -m memsql -c '/var/lib/memsql/service start' && tail -F /var/lib/memsql/tracelogs/memsql.log
#CMD /opt/memsql/entry.sh
CMD /var/lib/memsql/memsqld -u memsql

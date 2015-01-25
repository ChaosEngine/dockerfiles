FROM ubuntu:latest
MAINTANER Chaos Engine <haos.engine@gmail.com>

#ENV MEMSQLKEY=12c197e246da4c5cbb23afccbb82cc28

RUN sudo apt-get -y update \
	&& sudo apt-get -y install make gcc g++ build-essential libgssapi-krb5-2 libwrap0 mysql-client \
	&& mkdir /opt/memsql

ADD binaries /opt/memsql

RUN cd /opt/memsql \
	&& dpkg -i memsql-3.2.x86_64.deb \
	&& chsh -s /bin/bash memsql

EXPOSE 3306

#CMD su -m memsql -c '/var/lib/memsql/service start' && tail -F /var/lib/memsql/tracelogs/memsql.log
#CMD /opt/memsql/entry.sh
CMD /var/lib/memsql/memsqld -u memsql

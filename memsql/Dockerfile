FROM debian:bookworm-20231009
MAINTAINER Chaos Engine <haos.engine@gmail.com>

ENV MEMSQL="memsql-ops-5.1.0"

#dependency include g++, mysql-client officially. Unofficialy it needs procps (coz of free) and libgssapi-krb5-2
#install *.deb and if successfull, remove downloaded *.deb
RUN apt-get -y update && apt-get -y install \
	wget \
	procps \
	g++ \
	libgssapi-krb5-2 \
	mysql-client \
	&& wget -q "http://download.memsql.com/${MEMSQL}/${MEMSQL}.tar.gz" \
	&& apt-get purge -y --auto-remove wget \
	&& tar xf ${MEMSQL}.tar.gz \
	&& cd "${MEMSQL}/memsql-ops" \
	&& printf y\\n | ./memsql-ops agent-install \
	&& /var/lib/memsql-ops/memsql-ops stop \
	&& /var/lib/memsql/leaf-3307/service stop \
	&& /var/lib/memsql/master-3306/service stop \
	&& sleep 30

RUN rm -rf /${MEMSQL}.tar.gz /${MEMSQL}
RUN ls -l /var/lib/memsql/

#using mysql listening port
EXPOSE 3306
EXPOSE 9000

#CMD /var/lib/memsql/service -u memsql start
CMD /var/lib/memsql-ops/memsql-ops start && /var/lib/memsql-ops/memsql-ops memsql-start --all && tail -f /var/lib/memsql/master-3306/tracelogs/memsql.log

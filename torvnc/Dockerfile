# DOCKER-VERSION 1.12.0-rc4
# Tor Over VNC

FROM debian:jessie

# Install vnc, xvfb in order to create a 'fake' display and firefox, tor-browser packages (get deps)
# We need sudo because some post install stuff runs with tor
RUN apt-get update && \
	apt-get install -y sudo wget xz-utils gnupg x11vnc xvfb fluxbox ca-certificates \
	libasound2 libdbus-glib-1-2 libgtk2.0-0 libxrender1 libxt6

ENV TOR_VERSION 6.5a2
ENV TOR_FINGERPRINT 0x4E2C6E8793298290

#### Get and extract Tor Browser bundle with verification####
RUN wget -q "https://dist.torproject.org/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz" "https://dist.torproject.org/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc" && \
	mkdir ~/.gnupg && \
	gpg --keyserver pool.sks-keyservers.net --recv-keys $TOR_FINGERPRINT && \
	gpg --fingerprint $TOR_FINGERPRINT | grep "Key fingerprint = EF6E 286D DA85 EA2A 4BA7  DE68 4E2C 6E87 9329 8290" && \
	gpg --verify "tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc" "tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz" && \
	tar xf "tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz" && \
	rm -rf "tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz" "tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc" ~/.gnupg
####/Bundle####

####user section####
RUN export uid=1001 gid=1001 && \
	mkdir -p /home/developer && \
	echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
	echo "developer:x:${uid}:" >> /etc/group && \
	echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
	chmod 0440 /etc/sudoers.d/developer && \
	chown ${uid}:${gid} -R /home/developer tor-browser_en-US

USER developer
ENV HOME /home/developer
###/user section####

####Setup a VNC password####
RUN mkdir ~/.vnc && \
	x11vnc -storepasswd somekindavncpassw0rd ~/.vnc/passwd
# Nasty way to start Tor
RUN bash -c 'echo -e "startfluxbox &\ncd tor-browser_en-US\n./start-tor-browser.desktop" >> ~/.bashrc'

EXPOSE 5900
####/Setup VNC####

CMD ["x11vnc", "-forever", "-usepw", "-create"]

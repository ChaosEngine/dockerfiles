# DOCKER-VERSION 18.06.1-ce
# Tor Over VNC

FROM debian:latest

# Install vnc in order to create a 'fake' display and firefox, tor-browser packages (get deps)
# We need sudo because some post install stuff runs with tor
RUN apt-get update && \
	apt-get install -y sudo wget xz-utils gnupg tightvncserver xterm fluxbox ca-certificates \
	libasound2 libdbus-glib-1-2 libgtk-3-0 libxrender1 libxt6 procps

ENV TOR_FINGERPRINT=0x4E2C6E8793298290 TOR_VERSION=8.0.9

#### Get and extract Tor Browser bundle with verification####
RUN wget -q "https://dist.torproject.org/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz" "https://dist.torproject.org/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc"
RUN	mkdir ~/.gnupg chmod 600 ~/.gnupg/* && chmod 700 ~/.gnupg && \
	gpg --no-tty --keyserver pool.sks-keyservers.net --recv-keys $TOR_FINGERPRINT && \
	gpg --no-tty --fingerprint $TOR_FINGERPRINT | grep "EF6E 286D DA85 EA2A 4BA7  DE68 4E2C 6E87 9329 8290" && \
	gpg --no-tty --verify "tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc" "tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz" && \
	tar xf "tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz" && \
	rm -rf "tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz" "tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc" ~/.gnupg
####/Bundle####

####user section####
ENV USER=developer
ENV HOME "/home/$USER"
RUN useradd --create-home --home-dir $HOME --shell /bin/bash $USER && \
	mkdir $HOME/.vnc/
COPY vnc.sh xstartup $HOME/.vnc/
RUN chmod 760 $HOME/.vnc/vnc.sh $HOME/.vnc/xstartup && \
	chown -R $USER:$USER $HOME tor-browser_en-US

USER "$USER"
###/user section####

####Setup a VNC password####
RUN	echo vncpassw | vncpasswd -f > ~/.vnc/passwd && \
	chmod 600 ~/.vnc/passwd

EXPOSE 5901
####/Setup VNC####

CMD ["/home/developer/.vnc/vnc.sh"]

# DOCKER-VERSION 1.12.0-rc4
# Tor Over VNC

FROM ubuntu:14.04
RUN apt-get update
# We need sudo because some post install stuff runs with tor
RUN apt-get install -y sudo wget xz-utils

# Get and extract Tor Browser bundle
RUN wget -q "https://dist.torproject.org/torbrowser/6.5a1/tor-browser-linux64-6.5a1_en-US.tar.xz" && \
	tar xf tor-browser-linux64-6.5a1_en-US.tar.xz

# Install vnc, xvfb in order to create a 'fake' display and firefox, tor-browser packages (get deps)
RUN apt-get install -y x11vnc xvfb twm && \
	apt-get install -y $(apt-cache depends firefox | grep Depends | sed "s/.*ends:\ //" | tr '\n' ' ')

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

# Setup a VNC password
RUN mkdir ~/.vnc && \
	x11vnc -storepasswd somekindavncpassw0rd ~/.vnc/passwd
# Nasty way to start Tor
RUN bash -c 'echo -e "twm &\ncd tor-browser_en-US\n./start-tor-browser.desktop" >> ~/.bashrc'

# VNC
EXPOSE 5900

CMD ["x11vnc", "-forever", "-usepw", "-create"]

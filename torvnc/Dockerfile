# DOCKER-VERSION 0.5.3
# Tor Over VNC

FROM ubuntu:14.04
RUN apt-get update
#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
# We need sudo because some post install stuff runs with tor
RUN apt-get install -y python-software-properties software-properties-common python3-software-properties sudo wget
RUN add-apt-repository -y ppa:upubuntu-com/tor && apt-get update

# Get and extract Tor Browser bundle
RUN wget "https://dist.torproject.org/torbrowser/5.5a3/tor-browser-linux64-5.5a3_pl.tar.xz"
RUN tar xvf tor-browser-linux64-5.5a3_pl.tar.xz
# The start script will exit if you're running as root - kill that (this is nasty and should be one sed not 4)
#RUN cd tor-browser_pl && sed -i '114 s/^/#/' start-tor-browser && sed -i '115 s/^/#/' start-tor-browser && sed -i '116 s/^/#/' start-tor-browser && sed -i '117 s/^/#/' start-tor-browser

# Install vnc, xvfb in order to create a 'fake' display and firefox, tor-browser packages (get deps)
RUN apt-get install -y x11vnc xvfb firefox

# Setup a VNC password
RUN mkdir ~/.vnc
RUN x11vnc -storepasswd somekindavncpassw0rd ~/.vnc/passwd
# Nasty way to start Tor
RUN bash -c 'echo "tor-browser_en-US/start-tor-browser" >> /.bashrc'

# VNC
EXPOSE 5900
# Internets!
EXPOSE 80
EXPOSE 443
# Tor Proxy
EXPOSE 9050

CMD    ["x11vnc", "-forever", "-usepw", "-create"]

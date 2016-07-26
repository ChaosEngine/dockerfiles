FROM sath89/oracle-12c
RUN apt-get update

# Install vnc, xvfb in order to create a 'fake' display
RUN apt-get install -y x11vnc x11-xserver-utils xvfb twm

# Setup a VNC password
RUN mkdir ~/.vnc && \
x11vnc -storepasswd somekindavncpassw0rd ~/.vnc/passwd
# Nasty way to start Tor
RUN bash -c 'echo -e "twm &\nxhost +" >> ~/.bashrc'

# VNC
EXPOSE 5900

CMD ["x11vnc", "-forever", "-usepw", "-create"]

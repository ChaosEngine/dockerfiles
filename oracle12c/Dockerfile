FROM sath89/oracle-12c

# Install vnc, xvfb in order to create a 'fake' display
RUN apt-get update && \
	apt-get install -y fluxbox tightvncserver xterm

ENV USER oracle

# Setup a VNC password
RUN mkdir /root/.vnc && \
	echo password | vncpasswd -f > /root/.vnc/passwd && \
# NASTY WAY TO START fluxbox with term
	bash -c 'echo -e "xhost + &\nxsetroot -solid grey &\nxterm -geometry 80x24+0+0i &\nstartfluxbox\nvncserver -kill :1\npkill tail" >> /root/.vnc/xstartup' && \
	chmod 600 /root/.vnc/passwd && chmod 760 /root/.vnc/xstartup

# VNC
EXPOSE 5901

#CMD ["x11vnc", "-forever", "-usepw", "-create"]
COPY vnc.sh /root/.vnc/
CMD ["/root/.vnc/vnc.sh"]

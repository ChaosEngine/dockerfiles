FROM sath89/oracle-12c
RUN apt-get update

# Install vnc, xvfb in order to create a 'fake' display
RUN apt-get install -y twm tightvncserver xterm

ENV USER oracle

# Setup a VNC password
RUN mkdir ~/.vnc && \
	echo password | vncpasswd -f > ~/.vnc/passwd && \
	bash -c 'echo -e "xhost + &\nxsetroot -solid grey &\ntwm &\nxterm -geometry 80x24+0+0" >> ~/.vnc/xstartup' && \
	chmod 600 ~/.vnc/passwd && chmod 760 ~/.vnc/xstartup


# NASTY WAY TO START TOR
#RUN bash -c 'echo -e "twm &\nxterm" >> ~/.bashrc'

# VNC
EXPOSE 5901

#CMD ["x11vnc", "-forever", "-usepw", "-create"]
COPY vnc.sh ~/.vnc/
CMD ["~/.vnc/vnc.sh"]

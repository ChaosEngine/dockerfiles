[![](https://images.microbadger.com/badges/image/chaosengine/torbrowser-vnc.svg)](https://microbadger.com/images/chaosengine/torbrowser-vnc "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/chaosengine/torbrowser-vnc.svg)](https://microbadger.com/images/chaosengine/torbrowser-vnc "Get your own version badge on microbadger.com")

Tor Browser accessible with VNC. Based much on excellent jfrazelle's tor-browser build.

How to run:

`docker run -it -p 5901:5901 chaosengine/torbrowser-vnc:latest`

then connect to :1 display with vncviewer
password: vncpassword

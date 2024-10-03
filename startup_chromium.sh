#!/bin/sh
export DISPLAY=:1

# Generate a random cookie
COOKIE=$(mcookie)

# Create the .Xauthority file with the cookie
xauth add $DISPLAY . $COOKIE

# Add this line to /home/chromiumuser/startup.sh
mkdir -p /tmp/.vnc && \
echo "${VNC_PASSWORD}" | vncpasswd -f > /tmp/.vnc/passwd

# Create the log dir
# mkdir -p /tmp/log/

# Start Xvnc server with authentication
Xvnc ${DISPLAY} -geometry "${VNC_GEOMETRY}" -depth "${VNC_DEPTH}" -SecurityTypes VncAuth -PasswordFile /tmp/.vnc/passwd -L *:stderr:100 -localhost 1 &

# Ensure Xvnc has time to start
sleep 2

# Start Openbox
openbox-session &

# Start Chromium 
 chromium-browser &

 #start novnc
 novnc_server --vnc 127.0.0.1:5901 --listen ${NOVNC_PORT}

wait
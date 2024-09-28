#!/bin/sh
export DISPLAY=:1

# Generate a random cookie
COOKIE=$(mcookie)

# Create the .Xauthority file with the cookie
xauth add $DISPLAY . $COOKIE

# Add this line to /home/chromiumuser/startup.sh
mkdir -p /home/chromiumuser/.vnc && \
echo "${VNC_PASSWORD}" | vncpasswd -f > /home/chromiumuser/.vnc/passwd

# Start Xvnc server with authentication
Xvnc ${DISPLAY} -geometry "${VNC_GEOMETRY}" -depth "${VNC_DEPTH}" -SecurityTypes VncAuth -PasswordFile /home/chromiumuser/.vnc/passwd -localhost 1 &

# Ensure Xvnc has time to start
sleep 2

# Start Openbox
openbox-session &

# Start Chromium 
 chromium-browser --renderer-process-limit=2 --disable-dev-shm-usage --max-old-space-size=2048 &

 #start novnc
 novnc_server --vnc 127.0.0.1:5901 --listen ${NOVNC_PORT}

wait

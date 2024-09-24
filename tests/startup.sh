#!/bin/sh
export DISPLAY=:1

# Generate a random cookie
COOKIE=$(mcookie)

# Create the .Xauthority file with the cookie
xauth add $DISPLAY . $COOKIE

# Start Xvnc server with authentication
Xvnc $DISPLAY -geometry 1280x800 -depth 24 -SecurityTypes VncAuth -PasswordFile /root/.vnc/passwd &

sleep 2

# Start Openbox
openbox-session &

# Start Firefox
firefox &

wait

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
Xvnc $DISPLAY -geometry 1280x800 -depth 24 -SecurityTypes VncAuth -PasswordFile /home/chromiumuser/.vnc/passwd &

sleep 2  # Ensure Xvnc has time to start

# Set the keyboard layout (e.g., to US English)
# setxkbmap us

# Start session-based DBus (important for non-root users)
eval $(dbus-launch --sh-syntax)

# Start Openbox
openbox-session &

# Start Chromium 
 chromium-browser &

wait

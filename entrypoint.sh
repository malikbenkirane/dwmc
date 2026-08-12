#!/bin/sh

# Start the X virtual framebuffer
Xvfb :0 -screen 0 "${RESOLUTION}" -ac &

# Wait until the X display is ready
for i in $(seq 1 30); do
    if [ -S /tmp/.X11-unix/X0 ]; then
        break
    fi
    sleep 0.5
done

# Start the window manager, set the background, and open a terminal
DISPLAY=:0 dwm &
DISPLAY=:0 xsetroot -solid '#282828' &
DISPLAY=:0 st &

# Start the VNC server in the foreground
if [ -n "${VNC_PASSWORD}" ]; then
    exec x11vnc -display :0 -forever -shared -passwd "${VNC_PASSWORD}" -listen 0.0.0.0 -rfbport 5900
else
    exec x11vnc -display :0 -forever -shared -nopw -listen 0.0.0.0 -rfbport 5900
fi

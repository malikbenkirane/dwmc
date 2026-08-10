FROM alpine:3.20

# Install X11 virtual framebuffer, dwm, VNC server, terminal, and fonts
RUN apk add --no-cache \
    xvfb \
    dwm \
    dmenu \
    st \
    xterm \
    x11vnc \
    xsetroot \
    font-dejavu \
    font-misc-misc

# X11 display and framebuffer resolution
ENV DISPLAY=:0
ENV RESOLUTION=1280x720x24

EXPOSE 5900

CMD ["sh", "-c", "Xvfb :0 -screen 0 ${RESOLUTION} -ac & sleep 1; DISPLAY=:0 dwm & DISPLAY=:0 xsetroot -solid '#282828' & DISPLAY=:0 st & x11vnc -display :0 -forever -shared -nopw -listen 0.0.0.0 -rfbport 5900"]

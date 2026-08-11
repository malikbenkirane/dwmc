FROM alpine:3.20

# Install X11 virtual framebuffer, VNC server, terminal, and fonts
RUN apk add --no-cache \
    xvfb \
    dmenu \
    st \
    xterm \
    x11vnc \
    xsetroot \
    font-dejavu \
    font-misc-misc \
    git \
    make \
    gcc \
    musl-dev \
    libx11-dev \
    libxft-dev \
    libxinerama-dev \
    fontconfig-dev

# Build dwm from source
RUN git clone https://git.suckless.org/dwm /tmp/dwm && \
    cd /tmp/dwm && make clean install && \
    rm -rf /tmp/dwm

# X11 display and framebuffer resolution
ENV DISPLAY=:0
ENV RESOLUTION=1280x720x24
ENV VNC_PASSWORD=

EXPOSE 5900

CMD sh -c "Xvfb :0 -screen 0 ${RESOLUTION} -ac & sleep 1; DISPLAY=:0 dwm & DISPLAY=:0 xsetroot -solid '#282828' & DISPLAY=:0 st & if [ -n \"${VNC_PASSWORD}\" ]; then x11vnc -display :0 -forever -shared -passwd \"${VNC_PASSWORD}\" -listen 0.0.0.0 -rfbport 5900; else x11vnc -display :0 -forever -shared -nopw -listen 0.0.0.0 -rfbport 5900; fi"

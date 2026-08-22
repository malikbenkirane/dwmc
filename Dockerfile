FROM debian:12.15-slim

# Install TigerVNC server, terminal, fonts, sudo, and browser
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    tigervnc-standalone-server \
    dmenu \
    stterm \
    xterm \
    xinit \
    x11-apps \
    fonts-dejavu \
    xfonts-base \
    git \
    make \
    gcc \
    libc6-dev \
    libx11-dev \
    libxft-dev \
    libxinerama-dev \
    libfontconfig-dev \
    sudo \
    chromium \
    firefox-esr \
    dbus \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Build dwm from source
RUN git clone https://git.suckless.org/dwm /tmp/dwm && \
    cd /tmp/dwm && make clean install && \
    rm -rf /tmp/dwm

# Create the agent user with passwordless sudo access
RUN useradd -m -s /bin/sh agent && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/agent && \
    chmod 0440 /etc/sudoers.d/agent

# Pre-create the X11 socket directory so Xvnc can run as a non-root user
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Chromium wrapper with flags for headless container (no GPU, no sandbox)
RUN printf '#!/bin/sh\nexec /usr/bin/chromium --no-sandbox --disable-gpu --disable-dev-shm-usage --disable-software-rasterizer "$@"\n' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# X11 display, geometry, and DPI
ENV DISPLAY=:0
ENV GEOMETRY=1920x1080
ENV DEPTH=24
ENV DPI=100
ENV VNC_PASSWORD=
ENV SHELL=/usr/bin/bash

# Copy the session entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5900

# Run the X session as the agent user
USER agent
WORKDIR /home/agent

ENTRYPOINT ["/entrypoint.sh"]

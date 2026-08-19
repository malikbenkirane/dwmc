FROM debian:12.15-slim

# Install X11 virtual framebuffer, VNC server, terminal, fonts, sudo, and browser
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xvfb \
    dmenu \
    stterm \
    xterm \
    x11vnc \
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

# Pre-create the X11 socket directory so Xvfb can run as a non-root user
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Chromium wrapper with flags for headless container (no GPU, no sandbox)
RUN printf '#!/bin/sh\nexec /usr/bin/chromium --no-sandbox --disable-gpu --disable-dev-shm-usage --disable-software-rasterizer "$@"\n' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# Symlink firefox command to firefox-esr for compatibility
RUN ln -s /usr/bin/firefox-esr /usr/bin/firefox

# X11 display and framebuffer resolution
ENV DISPLAY=:0
ENV RESOLUTION=1280x720x24
ENV VNC_PASSWORD=

# Copy the session entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5900

# Run the X session as the agent user
USER agent
WORKDIR /home/agent

ENTRYPOINT ["/entrypoint.sh"]

FROM alpine:3.20

# Install Wayland compositor, VNC server, and supporting tools
RUN apk add --no-cache \
    labwc \
    wayvnc \
    foot \
    mesa-dri-gallium \
    xvfb-run

# Configure strict XDG environment requirements
ENV XDG_RUNTIME_DIR=/tmp/runtime-dir
ENV WAYLAND_DISPLAY=wayland-0

RUN mkdir -p ${XDG_RUNTIME_DIR} && \
    chmod 700 ${XDG_RUNTIME_DIR}

EXPOSE 5900

RUN apk add --no-cache cage

CMD ["sh", "-c", "WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_RENDERER_ALLOW_SOFTWARE=1 WLR_LIBINPUT_NO_DEVICES=1 WLR_HEADLESS_OUTPUTS=1 cage foot & until [ -S ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY} ]; do sleep 0.1; done; sleep 1; wayvnc 0.0.0.0 5900"]


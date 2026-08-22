# dwmc

Containerized X11/VNC desktop environment with development tools, built on Debian Bookworm.

## Architecture

Three images built in sequence:

| Image | Dockerfile | Description |
|-------|-----------|-------------|
| `dwmc:tools` | `tools/Dockerfile` | Standalone binaries (crush, jj) downloaded as tarballs |
| `dwmc:bookworm` | `Dockerfile` | Base desktop: Xvfb, x11vnc, dwm, st, Chromium, Firefox |
| `dwmc:core` | `core/Dockerfile` | Full dev environment: Go, fonts, gcloud CLI, tools from `dwmc:tools` |
| `dwmc:golang` | `golang/Dockerfile` | Go LSP and debugging tools (gopls, golangci-lint, dlv) layered on `dwmc:core` |

`core/Dockerfile` uses a multi-stage build: it pulls pre-built binaries from `dwmc:tools` via `COPY --from=tools`, then layers system packages and development tools on top of `dwmc:bookworm`.

## Building

```sh
./build.sh
```

This builds all three images in order. The `CONTAINER_RUNTIME` environment variable defaults to `container` and can be overridden:

```sh
CONTAINER_RUNTIME=docker ./build.sh
```

## Running

```sh
container run -p 5900:5900 dwmc:core
```

Connect to `localhost:5900` with any VNC client. Set `VNC_PASSWORD` for authenticated access:

```sh
container run -p 5900:5900 -e VNC_PASSWORD=secret dwmc:core
```

### Common use

A typical workflow: mount your project and host configs (gcloud, crush, helix) into the container, run it detached with resource limits, then connect via VNC:

```sh
container run --rm -d \
  -v ~/.config/gcloud:/home/agent/.config/gcloud \
  -v ~/.config/crush/:/home/agent/.config/crush \
  -v ~/.config/helix/:/home/agent/.config/helix \
  -v ~/uc:/home/agent/uc --name uc \
  --memory 8G --cpus 8 \
  dwmc:golang
```

Connect to the container's VNC port (e.g. with TigerVNC) and you get a full desktop with access to your host gcloud credentials, Crush, and Helix configuration, working on project `uc`.

### Display resolution and DPI

The framebuffer geometry and DPI are configurable via env vars, with defaults tuned for Retina-class displays:

| Variable | Default | Description |
|----------|---------|-------------|
| `RESOLUTION` | `1280x720x24` | `WxHxdepth` passed to `Xvfb -screen 0` |
| `DPI` | `100` | DPI passed to `Xvfb -dpi` (affects font and UI scaling) |

Override either at run time:

```sh
container run -p 5900:5900 -e RESOLUTION=1920x1080x24 -e DPI=96 dwmc:core
```

## Troubleshooting

### Build fails with "Temporary failure resolving" DNS errors

**Symptom:** `apt-get update` fails during a non-cached build layer with:

```
Temporary failure resolving 'deb.debian.org'
E: Package 'gnupg' has no installation candidate
```

Cached layers resolve fine because they are not re-executed. Only new (non-cached) layers that need network access fail.

**Cause:** The macOS Container framework's build environment (`container build`) does not inherit DNS from the host by default. The default resolver (`192.168.65.1`) may not be reachable from the build sandbox.

**Fix:** Configure DNS servers in the container runtime config:

```sh
mkdir -p ~/.config/container
cat > ~/.config/container/config.toml << 'EOF'
[dns]
servers = ["8.8.8.8", "8.8.4.4"]
EOF
```

Then restart the container runtime for the change to take effect:

```sh
container system stop
container system start
```

Note: `/etc/resolv.conf` is read-only inside build layers, so DNS cannot be overridden from within a `RUN` step.

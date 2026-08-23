# dwmc

Containerized X11/VNC desktop environment with development tools, built on Debian Bookworm.

## Architecture

Three images built in sequence:

| Image | Dockerfile | Description |
|-------|-----------|-------------|
| `dwmc:tools` | `tools/Dockerfile` | Standalone binaries (crush, jj) downloaded as tarballs |
| `dwmc:bookworm` | `Dockerfile` | Base desktop: TigerVNC, dwm, st, Chromium, Firefox |
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

### Customizing tool versions

The tools image downloads pre-built binaries at pinned versions. Override them with `--build-arg` when building the tools image directly:

| Build arg | Default | Tool |
|-----------|---------|------|
| `GIT_VERSION` | `2.55.0` | Git (compiled from source) |
| `CRUSH_VERSION` | `0.90.0` | Crush |
| `HELIX_VERSION` | `25.07.1` | Helix editor |
| `RIPGREP_VERSION` | `15.2.0` | ripgrep |
| `GH_VERSION` | `2.98.0` | GitHub CLI |

`build.sh` rebuilds all four images in sequence, so build the tools image first with your overrides, then run the full script (cached layers will be reused):

```sh
container build --build-arg CRUSH_VERSION=0.92.0 -t dwmc:tools ./tools
./build.sh
```

## Running

```sh
container run -d dwmc:core
```

The container is accessible on the host subnet. Find its IP with `container ls`, then connect to port 5900 with any VNC client. Set `VNC_PASSWORD` for authenticated access:

```sh
container run -d -e VNC_PASSWORD=secret dwmc:core
```

### Common use

A typical workflow: mount your project and host configs (gcloud, crush, helix) into the container, run it detached with resource limits, then connect via VNC:

```sh
container run -d \
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
| `GEOMETRY` | `1920x1080` | `WxH` passed to `vncserver -geometry` |
| `DEPTH` | `24` | Pixel depth in bits, passed to `vncserver -depth` |
| `DPI` | `100` | DPI passed to `vncserver -dpi` (affects font and UI scaling) |

Override at run time:

```sh
container run -e GEOMETRY=1280x720 -e DPI=96 dwmc:core
```

## Environment variables

The core image defines several additional environment variables beyond display settings:

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_PASSWORD` | *(empty)* | VNC authentication password. When empty, VNC runs with `SecurityTypes None` (no authentication). |
| `LITELLM_HOST` | `192.168.65.1` | IP address mapped to `litellm.test` in `/etc/hosts` at container startup. Override if your LLM proxy runs on a different address. |
| `EDITOR` | `hx` | Default editor for tools that respect `$EDITOR` (e.g., git, crush). |
| `SHELL` | `/usr/bin/bash` | Default shell for the agent user. |
| `DISPLAY` | `:0` | X11 display identifier. The VNC server always starts on `:0`. |

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

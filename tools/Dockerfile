FROM debian:12.15-slim

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
ARG CRUSH_VERSION=0.90.0
RUN arch=$(case "$TARGETARCH" in amd64) echo x86_64;; arm64) echo arm64;; esac) && \
    curl -fsSL "https://github.com/charmbracelet/crush/releases/download/v${CRUSH_VERSION}/crush_${CRUSH_VERSION}_Linux_${arch}.tar.gz" -o /tmp/crush.tar.gz && \
    tar -xzf /tmp/crush.tar.gz -C /tmp && \
    install -m 755 "/tmp/crush_${CRUSH_VERSION}_Linux_${arch}/crush" /usr/local/bin/crush && \
    rm -rf /tmp/crush.tar.gz "/tmp/crush_${CRUSH_VERSION}_Linux_${arch}"

RUN arch=$(case "$TARGETARCH" in amd64) echo x86_64;; arm64) echo aarch64;; esac) && \
    curl -fsSL "https://github.com/jj-vcs/jj/releases/download/v0.44.0/jj-v0.44.0-${arch}-unknown-linux-musl.tar.gz" -o /tmp/jj.tar.gz && \
    tar -xzf /tmp/jj.tar.gz -C /tmp && \
    install -m 755 /tmp/jj /usr/local/bin/jj && \
    rm -rf /tmp/jj.tar.gz /tmp/jj

RUN curl -fsSL "http://deb.debian.org/debian/pool/main/x/xz-utils/xz-utils_5.4.1-1+deb12u1_${TARGETARCH}.deb" -o /tmp/xz-utils.deb && \
    dpkg -i /tmp/xz-utils.deb && \
    rm /tmp/xz-utils.deb

ARG HELIX_VERSION=25.07.1
RUN arch=$(case "$TARGETARCH" in amd64) echo x86_64;; arm64) echo aarch64;; esac) && \
    curl -fsSL "https://github.com/helix-editor/helix/releases/download/${HELIX_VERSION}/helix-${HELIX_VERSION}-${arch}-linux.tar.xz" -o /tmp/helix.tar.xz && \
    tar -xJf /tmp/helix.tar.xz -C /tmp && \
    install -m 755 "/tmp/helix-${HELIX_VERSION}-${arch}-linux/hx" /usr/local/bin/hx && \
    cp -r "/tmp/helix-${HELIX_VERSION}-${arch}-linux/runtime" /usr/local/lib/helix-runtime && \
    rm -rf /tmp/helix.tar.xz "/tmp/helix-${HELIX_VERSION}-${arch}-linux"
ENV HELIX_RUNTIME=/usr/local/lib/helix-runtime

ARG RIPGREP_VERSION=15.2.0
RUN arch=$(case "$TARGETARCH" in amd64) echo x86_64;; arm64) echo aarch64;; esac) && \
    curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-${arch}-unknown-linux-musl.tar.gz" -o /tmp/ripgrep.tar.gz && \
    tar -xzf /tmp/ripgrep.tar.gz -C /tmp && \
    install -m 755 "/tmp/ripgrep-${RIPGREP_VERSION}-${arch}-unknown-linux-musl/rg" /usr/local/bin/rg && \
    rm -rf /tmp/ripgrep.tar.gz "/tmp/ripgrep-${RIPGREP_VERSION}-${arch}-unknown-linux-musl"

WORKDIR /workspace

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

WORKDIR /workspace

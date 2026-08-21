FROM debian:12.15-slim

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
RUN arch=$(case "$TARGETARCH" in amd64) echo x86_64;; arm64) echo aarch64;; esac) && \
    curl -fsSL "https://github.com/jj-vcs/jj/releases/download/v0.44.0/jj-v0.44.0-${arch}-unknown-linux-musl.tar.gz" -o /tmp/jj.tar.gz && \
    tar -xzf /tmp/jj.tar.gz -C /tmp && \
    install -m 755 /tmp/jj /usr/local/bin/jj && \
    rm -rf /tmp/jj.tar.gz /tmp/jj

WORKDIR /workspace

FROM rust:1-bookworm AS git-builder
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential curl ca-certificates zlib1g-dev libssl-dev libexpat1-dev \
    libcurl4-gnutls-dev gettext && \
    rm -rf /var/lib/apt/lists/*
ARG GIT_VERSION=2.55.0
RUN curl -fsSL "https://kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz" -o /tmp/git.tar.gz && \
    tar -xzf /tmp/git.tar.gz -C /tmp && \
    cd "/tmp/git-${GIT_VERSION}" && \
    make prefix=/opt/git NO_TCLTK=1 all -j$(nproc) && \
    make prefix=/opt/git NO_TCLTK=1 install && \
    rm -rf /tmp/git.tar.gz "/tmp/git-${GIT_VERSION}"

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

ARG JJ_VERSION=0.44.0
RUN arch=$(case "$TARGETARCH" in amd64) echo x86_64;; arm64) echo aarch64;; esac) && \
    curl -fsSL "https://github.com/jj-vcs/jj/releases/download/v${JJ_VERSION}/jj-v${JJ_VERSION}-${arch}-unknown-linux-musl.tar.gz" -o /tmp/jj.tar.gz && \
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

ARG GH_VERSION=2.98.0
RUN arch=$(case "$TARGETARCH" in amd64) echo amd64;; arm64) echo arm64;; esac) && \
    curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${arch}.tar.gz" -o /tmp/gh.tar.gz && \
    tar -xzf /tmp/gh.tar.gz -C /tmp && \
    install -m 755 "/tmp/gh_${GH_VERSION}_linux_${arch}/bin/gh" /usr/local/bin/gh && \
    rm -rf /tmp/gh.tar.gz "/tmp/gh_${GH_VERSION}_linux_${arch}"

COPY --from=git-builder /opt/git /opt/git
ENV PATH="/opt/git/bin:${PATH}"

WORKDIR /workspace

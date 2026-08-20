FROM dwmc:bookworm

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends htop curl unzip && \
    rm -rf /var/lib/apt/lists/*

# Install Go from official binary release
RUN \
    curl -fsSL https://go.dev/dl/go1.26.5.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

USER agent
WORKDIR /home/agent

# Install ProggyClean Nerd Font
RUN curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.0/ProggyClean.zip -o /tmp/ProggyClean.zip && \
    mkdir -p /home/agent/.local/share/fonts && \
    unzip -o /tmp/ProggyClean.zip -d /tmp/proggyclean && \
    find /tmp/proggyclean -name '*.ttf' -exec cp {} /home/agent/.local/share/fonts/ \; && \
    rm -rf /tmp/ProggyClean.zip /tmp/proggyclean && \
    fc-cache -f

# Install Aporetic Nerd Font
RUN git clone https://github.com/Echinoidea/Aporetic-Nerd-Font /tmp/aporetic && \
    cd /tmp/aporetic && git checkout 88ae58a && \
    find . -name '*.ttf' -exec cp {} /home/agent/.local/share/fonts/ \; && \
    rm -rf /tmp/aporetic && \
    fc-cache -f

# Build and install patched st
COPY --chown=agent:agent st.diff /tmp/st.diff
RUN git clone https://git.suckless.org/st /tmp/st && \
    cd /tmp/st && git checkout 0.9.2 && \
    git apply /tmp/st.diff && \
    make && sudo make install && \
    rm -rf /tmp/st /tmp/st.diff

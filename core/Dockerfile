FROM dwmc:tools AS tools

FROM dwmc:bookworm

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends htop curl unzip && \
    rm -rf /var/lib/apt/lists/*

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

# Install Google Cloud CLI and GKE auth plugin
USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gnupg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
      | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update && \
    CLOUDSDK_SKIP_PY_COMPILATION=1 apt-get install -y --no-install-recommends \
      google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin && \
    rm -rf /var/lib/apt/lists/*

# Copy pre-built tools from the tools stage
USER root
COPY --from=tools /usr/local/bin/crush /usr/local/bin/crush
COPY --from=tools /usr/local/bin/jj /usr/local/bin/jj
COPY --from=tools /usr/local/bin/hx /usr/local/bin/hx
COPY --from=tools /usr/local/lib/helix-runtime /usr/local/lib/helix-runtime
ENV HELIX_RUNTIME=/usr/local/lib/helix-runtime

USER agent

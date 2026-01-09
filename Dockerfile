FROM n8nio/n8n:latest

ARG SUDO_PASSWORD

USER root

RUN apt update && apt install -y ffmpeg sudo bash coreutils bc python3 python3-pip && rm -rf /var/lib/apt/lists/*
RUN apt update && apt install -y chromium chromium-driver && rm -rf /var/lib/apt/lists/*
RUN export PATH=/usr/bin:/usr/lib/chromium:$PATH

# usage: echo "$SUDO_PASSWORD" | sudo -S your-command-here
RUN echo "node:${SUDO_PASSWORD}" | chpasswd && \
    echo "node ALL=(ALL) ALL" > /etc/sudoers.d/node && \
    chmod 0440 /etc/sudoers.d/node

USER node   
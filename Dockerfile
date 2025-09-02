FROM n8nio/n8n:latest

ARG SUDO_PASSWORD

USER root

RUN apk add --no-cache ffmpeg sudo shadow bash

# usage: echo "$SUDO_PASSWORD" | sudo -S your-command-here
RUN echo "node:${SUDO_PASSWORD}" | chpasswd && \
    echo "node ALL=(ALL) ALL" > /etc/sudoers.d/node && \
    chmod 0440 /etc/sudoers.d/node

USER node
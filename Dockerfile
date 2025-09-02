FROM n8nio/n8n:latest

ARG SUDO_PASSWORD

USER root

RUN apk add --no-cache ffmpeg sudo shadow

# usage: echo "$SUDO_PASSWORD" | sudo -S your-command-here
RUN echo "node:${SUDO_PASSWORD}" | chpasswd && \
    adduser node wheel

USER node
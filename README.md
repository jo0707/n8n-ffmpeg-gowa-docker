# n8n-ffmpeg-gowa-docker

This repository provides a quick start Docker Compose setup for running n8n with integrated FFmpeg and Go Whatsapp support.

This container using Debian base image instead of Alpine Linux base image, this was meant to support any browser automation and else.

## Purpose

-   Automate workflows using n8n
-   Enable media processing with FFmpeg
-   Whatsapp automation via Go Whatsapp

## Configuration

1. Edit the `docker-compose.yml` and `.env` files to customize your setup.
2. Edit packages installed inside n8n container and image version by modifying the Dockerfile.

> Warning: You may want to remove sudo access to n8n container for security reasons. Edit Dockerfile, remove sudo and chpassword related command from build steps.


## running

```bash
git clone https://github.com/jo0707/n8n-ffmpeg-gowa-docker
cd n8n-ffmpeg-gowa-docker
bash build.sh
```

If you need to update n8n version, just rerun build.sh.

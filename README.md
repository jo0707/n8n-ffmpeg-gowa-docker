# n8n-ffmpeg-gowa-docker

This repository provides a Docker Compose setup for running n8n with integrated FFmpeg and Go Whatsapp support.

## Purpose

-   Automate workflows using n8n
-   Enable media processing with FFmpeg
-   Whatsapp automation via Go Whatsapp

## Configuration

Edit the `docker-compose.yml` and `.env` files to customize your setup.

> Warning: You may want to remove sudo access to n8n container for security reasons. Edit Dockerfile, remove sudo and chuser command from build steps.

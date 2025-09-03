# syntax=docker/dockerfile:1
FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG SUDO_PASSWORD

ENV TZ=UTC \
    NODE_ENV=production \
    N8N_PORT=5678 \
    CHROME_PATH=/usr/bin/google-chrome-stable \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable \
    PATH=/usr/bin:/usr/local/bin:$PATH

# 1) Base tools & libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg wget apt-transport-https \
    xz-utils unzip git bash sudo coreutils bc tini \
    python3 python3-pip python3-venv \
    ffmpeg \
    adduser passwd \
    # Chrome runtime libs
    fonts-liberation libasound2 libnss3 libnspr4 libxss1 xdg-utils libgbm1 \
  && rm -rf /var/lib/apt/lists/*

# 2) Node.js 20 (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

# 3) Google Chrome Stable + chromedriver
RUN mkdir -p /usr/share/keyrings \
  && wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
     | gpg --dearmor > /usr/share/keyrings/google-linux-keyring.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
     > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update && apt-get install -y --no-install-recommends \
     google-chrome-stable \
     chromium-driver \
  && rm -rf /var/lib/apt/lists/*

# 4) n8n
RUN npm install -g n8n@latest

# 5) Python deps (TikTok uploader)
RUN pip3 install --no-cache-dir tiktok-uploader

# 6) Non-root user (like official n8n)
RUN useradd -ms /bin/bash node \
  && mkdir -p /home/node/.n8n /home/node/uploads \
  && chown -R node:node /home/node

# 7) Sudo for node (as in your Alpine file)
RUN if [ -n "$SUDO_PASSWORD" ]; then \
      echo "node:${SUDO_PASSWORD}" | chpasswd && \
      echo "node ALL=(ALL) ALL" > /etc/sudoers.d/node && \
      chmod 0440 /etc/sudoers.d/node ; \
    fi

WORKDIR /home/node
USER node

VOLUME ["/home/node/.n8n", "/home/node/uploads"]

EXPOSE 5678

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["n8n"]

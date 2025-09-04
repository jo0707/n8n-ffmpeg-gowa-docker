FROM debian:bookworm-slim AS basepkgs

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Base tools, Python, Chrome runtime libs (cached with BuildKit)
# PERUBAHAN: 'ffmpeg' dihapus dari daftar apt-get install di bawah ini
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
     ca-certificates curl gnupg wget apt-transport-https \
     xz-utils unzip git bash sudo coreutils bc tini \
     python3 python3-pip python3-venv \
     adduser passwd \
     fonts-liberation libasound2 libnss3 libnspr4 libxss1 xdg-utils libgbm1 \
    && rm -rf /var/lib/apt/lists/*

# --- TAMBAHAN: Instal FFmpeg Versi Statis Terbaru ---
# Mengunduh build statis terbaru, mengekstrak, dan menempatkannya di PATH.
RUN curl -L "https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz" -o /tmp/ffmpeg.tar.xz \
    && tar -xf /tmp/ffmpeg.tar.xz -C /tmp \
    && mv /tmp/ffmpeg-git-*-static/ffmpeg /usr/local/bin/ffmpeg \
    && mv /tmp/ffmpeg-git-*-static/ffprobe /usr/local/bin/ffprobe \
    && rm -rf /tmp/* \
    && ffmpeg -version # Verifikasi untuk melihat versi baru saat build

# Node.js 20 (LTS) via NodeSource
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Google Chrome Stable (+ optional ChromeDriver if you need Selenium)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    mkdir -p /usr/share/keyrings \
    && wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
       | gpg --dearmor > /usr/share/keyrings/google-linux-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
       > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y --no-install-recommends \
       google-chrome-stable \
       chromium-driver \
    && rm -rf /var/lib/apt/lists/*


############################
# Stage 2: runtime
############################
FROM basepkgs AS runtime

ARG SUDO_PASSWORD

ENV NODE_ENV=production \
    N8N_PORT=5678 \
    N8N_LISTEN_ADDRESS=0.0.0.0 \
    CHROME_PATH=/usr/bin/google-chrome-stable \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

RUN npm install -g n8n@latest sqlite3

RUN yes | pip3 install --no-cache-dir tiktok-uploader --break-system-packages

RUN useradd -ms /bin/bash node \
 && mkdir -p /home/node/.n8n /home/node/uploads \
 && chown -R node:node /home/node

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
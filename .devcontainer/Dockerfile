# Copied from https://github.com/anthropics/claude-code/blob/main/.devcontainer/Dockerfile on 2026-02-03

FROM node:20

ARG TZ
ENV TZ="$TZ"

# Install basic development tools, browser dependencies, and iptables/ipset
RUN apt-get update && apt-get install -y --no-install-recommends \
  aggregate \
  dnsutils \
  fzf \
  gh \
  git \
  gnupg2 \
  iproute2 \
  ipset \
  iptables \
  jq \
  less \
  libasound2 \
  libatk-bridge2.0-0 \
  libatk1.0-0 \
  libatspi2.0-0 \
  libcups2 \
  libdbus-1-3 \
  libgbm1 \
  libgtk-3-0 \
  libnspr4 \
  libnss3 \
  libx11-xcb1 \
  libxcomposite1 \
  libxcursor1 \
  libxdamage1 \
  libxfixes3 \
  libxkbcommon0 \
  libxrandr2 \
  locales \
  man-db \
  nano \
  procps \
  sudo \
  unzip \
  vim \
  zsh \
  && sed -i '/en_GB.UTF-8/s/^# //' /etc/locale.gen && locale-gen \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# System setup: legacy iptables, directories, and permissions
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy \
  && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy \
  && mkdir -p /usr/local/share/npm-global \
  && chown -R node:node /usr/local/share \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R node:node /commandhistory \
  && mkdir -p /workspace /home/node/.claude \
  && chown -R node:node /workspace /home/node/.claude

ENV LANG=en_GB.UTF-8
ENV LC_ALL=en_GB.UTF-8
ENV DEVCONTAINER=true

WORKDIR /workspace

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

ARG RUBY_VERSION=3.4.8
# Install rbenv, compile Ruby, then remove build dependencies to save image space
RUN apt-get update && apt-get install -y --no-install-recommends \
  autoconf \
  bison \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  libreadline-dev \
  libssl-dev \
  libyaml-dev \
  rustc \
  zlib1g-dev \
  && git clone https://github.com/rbenv/rbenv.git /home/node/.rbenv \
  && git clone https://github.com/rbenv/ruby-build.git /home/node/.rbenv/plugins/ruby-build \
  && RBENV_ROOT=/home/node/.rbenv /home/node/.rbenv/bin/rbenv install "${RUBY_VERSION}" \
  && RBENV_ROOT=/home/node/.rbenv /home/node/.rbenv/bin/rbenv global "${RUBY_VERSION}" \
  && chown -R node:node /home/node/.rbenv \
  && apt-get purge -y \
    autoconf \
    bison \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libreadline-dev \
    libssl-dev \
    libyaml-dev \
    rustc \
    zlib1g-dev \
  && apt-get autoremove -y \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up non-root user
USER node

# Environment configuration
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global \
  PATH=$PATH:/usr/local/share/npm-global/bin:/home/node/.local/bin:/home/node/.rbenv/bin:/home/node/.rbenv/shims \
  SHELL=/bin/zsh \
  EDITOR=vim \
  VISUAL=vim \
  NODE_OPTIONS="--max-old-space-size=4096" \
  CLAUDE_CONFIG_DIR="/home/node/.claude"

# Configure shell: rbenv integration and prevent SSH agent leaking
RUN echo 'eval "$(rbenv init - zsh)"' >> /home/node/.zshrc \
  && echo 'eval "$(rbenv init - bash)"' >> /home/node/.bashrc \
  && echo 'unset SSH_AUTH_SOCK' >> /home/node/.zshrc

# Pre-configure VS Code machine-level settings (applies to any workspace)
RUN mkdir -p /home/node/.vscode-server/data/Machine && \
  cat <<'EOF' > /home/node/.vscode-server/data/Machine/settings.json
{
  "editor.formatOnSave": true,
  "terminal.integrated.defaultProfile.linux": "zsh",
  "terminal.integrated.profiles.linux": {
    "bash": {
      "path": "bash",
      "icon": "terminal-bash"
    },
    "zsh": {
      "path": "zsh"
    }
  },
  "terminal.integrated.env.linux": {
    "SSH_AUTH_SOCK": null
  }
}
EOF

# Install Claude
ARG CLAUDE_CODE_VERSION=latest
RUN curl -fsSL https://claude.ai/install.sh | TARGET=${CLAUDE_CODE_VERSION} bash

# Install Playwright
RUN npm install -g playwright && playwright install

# Copy and set up firewall and entrypoint scripts
COPY init-firewall.sh entrypoint.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/entrypoint.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall
USER node

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["zsh"]

# Copied from https://github.com/anthropics/claude-code/blob/main/.devcontainer/Dockerfile on 2026-02-03

FROM node:20

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest

# Install basic development tools, browser dependencies and iptables/ipset
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
  man-db \
  nano \
  procps \
  sudo \
  unzip \
  vim \
  zsh \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Use legacy iptables as the apple/container kernel doesn't support the nftables kernel API
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set the default editor and visual
ENV EDITOR=vim
ENV VISUAL=vim

# Container environment (moved from devcontainer.json containerEnv)
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV CLAUDE_CONFIG_DIR="/home/node/.claude"
ENV POWERLEVEL9K_DISABLE_GITSTATUS="true"

# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

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
  }
}
EOF

# Install Claude
RUN curl -fsSL https://claude.ai/install.sh | TARGET=${CLAUDE_CODE_VERSION} bash

# Install Playwright
RUN npx playwright install

# Copy and set up firewall and entrypoint scripts
COPY init-firewall.sh entrypoint.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/entrypoint.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall
USER node

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["zsh"]
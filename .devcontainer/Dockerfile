FROM node:20

ARG TZ
ENV TZ="$TZ"
ENV TERM=xterm-256color

# Install basic development tools and iptables/ipset
RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  nano \
  vim \
  python3 \
  python3-pip \
  tmux \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Rename built-in node user to devc
RUN usermod -l devc node && \
  groupmod -n devc node && \
  usermod -d /home/devc -m devc

# Install zsh plugins/themes
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k

# Set shell to zsh
RUN chsh -s /bin/zsh devc

# Ensure devc user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R devc:devc /usr/local/share

ARG USERNAME=devc

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create tamper-resistant in-container marker (root-owned, non-root cannot modify)
RUN echo "1" > /etc/devcontainer && chmod 444 /etc/devcontainer

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/devc/.claude && \
  chown -R devc:devc /workspace /home/devc/.claude

WORKDIR /workspace

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Set up non-root user
USER devc

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set the default editor and visual
ENV EDITOR=vim
ENV VISUAL=vim

# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install uv, ruff, pyright
ENV PATH=$PATH:/home/devc/.local/bin
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
  uv tool install ruff && \
  uv tool install pyright

# Install Claude
RUN curl -fsSL https://claude.ai/install.sh | bash


# Copy and set up firewall script
#COPY .devcontainer/init-firewall.sh /usr/local/bin/
COPY init-firewall.sh /usr/local/bin/

USER root
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "devc ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/devc-firewall && \
  chmod 0440 /etc/sudoers.d/devc-firewall
USER devc
ENV SHELL=/bin/zsh

#!/usr/bin/env bash
set -e

if [ -f "$HOME/.setup_done" ]; then
  # Make sure initialization only runs once
  echo "Devcontainer already initialized — skipping setup"
  exit 0
fi

echo "Running devcontainer setup..."

# Firewall
echo "  Configuring firewall..."
sudo /usr/local/bin/init-firewall.sh

# SSH
echo "  Setting up SSH..."
mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null || true

# Dotfiles
if [ ! -d "$HOME/dotfiles" ]; then
  echo "  Installing dotfiles..."
  git clone git@github.com:lorenzoamir/dotfiles.git "$HOME/dotfiles"
  cd "$HOME/dotfiles"
  ./install.sh
else
  echo "  Dotfiles already installed"
fi

# Mark setup as done
touch "$HOME/.setup_done"

echo "Devcontainer setup complete!"


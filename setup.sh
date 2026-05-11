#!/bin/bash

# Linux Development Environment Setup Script
# Auto-configures: apt, git, oh-my-zsh, plugins, tmux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

confirm() {
    read -p "$1 [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This script is designed for Linux systems only."
    exit 1
fi

echo "=========================================="
echo "  Linux Development Environment Setup"
echo "=========================================="
echo ""

# Step 1: Fix apt sources and update
print_step "Step 1/6: Fixing apt sources and updating"

# Check for problematic Docker repository
if [ -f /etc/apt/sources.list.d/docker.list ] && grep -q "debian" /etc/apt/sources.list.d/docker.list; then
    print_warning "Found incorrect Docker repository (Debian on Ubuntu system)"
    if confirm "Fix Docker repository configuration?"; then
        # Backup the file
        sudo cp /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.list.backup.$(date +%Y%m%d_%H%M%S)

        # Remove or comment out the problematic line
        sudo sed -i 's|^deb.*download.docker.com/linux/debian|# &|' /etc/apt/sources.list.d/docker.list

        print_step "✓ Docker repository disabled (backup created)"
        print_warning "To properly install Docker on Ubuntu, run: curl -fsSL https://get.docker.com | sh"
    fi
fi

if confirm "Update apt? (Recommended)"; then
    # Update with error handling
    if sudo apt update 2>&1 | tee /tmp/apt-update.log; then
        print_step "✓ apt updated successfully"

        if confirm "Upgrade existing packages?"; then
            sudo apt upgrade -y
            print_step "✓ Packages upgraded"
        fi
    else
        print_warning "apt update completed with warnings (check /tmp/apt-update.log)"
        if confirm "Continue anyway?"; then
            print_step "Continuing with installation..."
        else
            print_error "Installation aborted by user"
            exit 1
        fi
    fi
else
    print_warning "Skipped apt update"
fi
echo ""

# Step 2: Install git
print_step "Step 2/6: Installing git"
if command -v git &> /dev/null; then
    print_warning "git is already installed ($(git --version))"
    if ! confirm "Reinstall git?"; then
        print_step "✓ Using existing git installation"
        echo ""
    else
        sudo apt install -y git
        print_step "✓ git reinstalled"
        echo ""
    fi
else
    sudo apt install -y git
    print_step "✓ git installed successfully"
    echo ""
fi

# Step 3: Install zsh
print_step "Step 3/6: Installing zsh"
if command -v zsh &> /dev/null; then
    print_warning "zsh is already installed ($(zsh --version))"
else
    sudo apt install -y zsh
    print_step "✓ zsh installed successfully"
fi
echo ""

# Step 4: Install oh-my-zsh
print_step "Step 4/6: Installing oh-my-zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_warning "oh-my-zsh is already installed"
    if confirm "Reinstall oh-my-zsh?"; then
        rm -rf "$HOME/.oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_step "✓ oh-my-zsh reinstalled"
    else
        print_step "✓ Using existing oh-my-zsh installation"
    fi
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_step "✓ oh-my-zsh installed successfully"
fi
echo ""

# Step 5: Install oh-my-zsh plugins
print_step "Step 5/6: Installing oh-my-zsh plugins"

# zsh-syntax-highlighting
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
HIGHLIGHT_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

if [ -d "$HIGHLIGHT_DIR" ]; then
    print_warning "zsh-syntax-highlighting already installed"
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HIGHLIGHT_DIR"
    print_step "✓ zsh-syntax-highlighting installed"
fi

# zsh-autosuggestions
AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"

if [ -d "$AUTOSUGGESTIONS_DIR" ]; then
    print_warning "zsh-autosuggestions already installed"
else
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$AUTOSUGGESTIONS_DIR"
    print_step "✓ zsh-autosuggestions installed"
fi

# Update .zshrc to enable plugins
if [ -f "$HOME/.zshrc" ]; then
    if grep -q "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" "$HOME/.zshrc"; then
        print_warning "Plugins already configured in .zshrc"
    else
        # Backup original .zshrc
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

        # Replace plugins line
        sed -i 's/^plugins=(.*/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' "$HOME/.zshrc"
        print_step "✓ Plugins configured in .zshrc (backup created)"
    fi
fi
echo ""

# Step 6: Install and configure tmux
print_step "Step 6/6: Installing and configuring tmux"

if command -v tmux &> /dev/null; then
    print_warning "tmux is already installed ($(tmux -V))"
else
    sudo apt install -y tmux
    print_step "✓ tmux installed successfully"
fi

# Create tmux configuration with mouse support and scrollback
TMUX_CONF="$HOME/.tmux.conf"

if [ -f "$TMUX_CONF" ]; then
    print_warning ".tmux.conf already exists"
    if confirm "Overwrite existing .tmux.conf?"; then
        cp "$TMUX_CONF" "$TMUX_CONF.backup.$(date +%Y%m%d_%H%M%S)"
        cat > "$TMUX_CONF" << 'EOF'
# Enable mouse support (scrolling, pane selection, resizing)
set -g mouse on

# Increase scrollback buffer size
set -g history-limit 10000

# Use vi mode for copy mode
setw -g mode-keys vi

# Start window numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Enable 256 color support
set -g default-terminal "screen-256color"

# Status bar styling
set -g status-style bg=black,fg=white
set -g status-left-length 40
set -g status-left "#[fg=green]Session: #S #[fg=yellow]#I #[fg=cyan]#P"
set -g status-right "#[fg=cyan]%d %b %R"

# Pane border styling
set -g pane-border-style fg=colour240
set -g pane-active-border-style fg=colour33

# Message styling
set -g message-style bg=colour235,fg=colour166

# Reload config with prefix + r
bind r source-file ~/.tmux.conf \; display "Config reloaded!"
EOF
        print_step "✓ .tmux.conf created (backup saved)"
    else
        print_step "✓ Using existing .tmux.conf"
    fi
else
    cat > "$TMUX_CONF" << 'EOF'
# Enable mouse support (scrolling, pane selection, resizing)
set -g mouse on

# Increase scrollback buffer size
set -g history-limit 10000

# Use vi mode for copy mode
setw -g mode-keys vi

# Start window numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Enable 256 color support
set -g default-terminal "screen-256color"

# Status bar styling
set -g status-style bg=black,fg=white
set -g status-left-length 40
set -g status-left "#[fg=green]Session: #S #[fg=yellow]#I #[fg=cyan]#P"
set -g status-right "#[fg=cyan]%d %b %R"

# Pane border styling
set -g pane-border-style fg=colour240
set -g pane-active-border-style fg=colour33

# Message styling
set -g message-style bg=colour235,fg=colour166

# Reload config with prefix + r
bind r source-file ~/.tmux.conf \; display "Config reloaded!"
EOF
    print_step "✓ .tmux.conf created"
fi
echo ""

# Final steps
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Change default shell to zsh:"
echo "   ${GREEN}chsh -s \$(which zsh)${NC}"
echo ""
echo "2. Log out and log back in for shell change to take effect"
echo ""
echo "3. Start using tmux:"
echo "   ${GREEN}tmux${NC}"
echo "   - Scroll with mouse wheel or Shift+PageUp/PageDown"
echo "   - Prefix key is Ctrl+b"
echo "   - Reload config: Ctrl+b then r"
echo ""
echo "4. Verify installations:"
echo "   git --version"
echo "   zsh --version"
echo "   tmux -V"
echo ""

if confirm "Change default shell to zsh now?"; then
    chsh -s $(which zsh)
    print_step "✓ Default shell changed to zsh"
    echo ""
    print_warning "Please log out and log back in for the change to take effect"
else
    print_warning "Remember to run: chsh -s \$(which zsh)"
fi

echo ""
echo "Setup script completed successfully!"

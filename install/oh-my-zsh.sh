#!/bin/bash
set -e

echo "=== Installing Zsh, Oh My Zsh, and plugins... ==="

#  Set default shell to zsh
if [ "$(echo $SHELL)" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    sudo chsh -s $(which zsh) $USER > /dev/null 2>&1
fi

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null 2>&1
else
    echo "oh-my-zsh is already installed."
fi

# Install zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > /dev/null 2>&1
else
    echo "zsh-autosuggestions is already installed."
fi

# Install zsh-autocomplete
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete" ]; then
    echo "Installing zsh-autocomplete..."
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete > /dev/null 2>&1
else
    echo "zsh-autocomplete is already installed."
fi

# Install zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting > /dev/null 2>&1
else
    echo "zsh-syntax-highlighting is already installed." > /dev/null 2>&1
fi

echo "-----------------------------------------"


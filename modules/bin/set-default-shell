#!/bin/bash

if [ "$(echo $SHELL)" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    sudo chsh -s $(which zsh) $USER > /dev/null 2>&1
fi
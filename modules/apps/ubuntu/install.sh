#!/bin/bash

if ! which brave-browser > /dev/null; then
  echo "Installing Brave Browser..."
  curl -fsS https://dl.brave.com/install.sh | sh > /dev/null
fi
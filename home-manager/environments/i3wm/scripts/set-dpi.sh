#!/bin/bash

# dpi-scale: 96-100% 120-125% 144-150% 192-200%
MONITOR=$(xrandr | grep " connected primary" | awk '{print $1}')

WIDTH=$(xrandr | grep "$MONITOR" | grep -oP '\d+x\d+' | cut -d'x' -f1)

if [ "$WIDTH" -gt 2000 ]; then
    DPI=120
else
    DPI=192
fi

echo "Xft.dpi: $DPI" | xrdb -merge


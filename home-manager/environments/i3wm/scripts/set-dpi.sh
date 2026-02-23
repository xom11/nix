#!/bin/bash

MONITOR=$(xrandr | grep " connected primary" | awk '{print $1}')

WIDTH=$(xrandr | grep "$MONITOR" | grep -oP '\d+x\d+' | cut -d'x' -f1)

if [ "$WIDTH" -gt 2000 ]; then
    DPI=144
else
    DPI=120
fi

echo "Xft.dpi: $DPI" | xrdb -merge

#  Cập nhật cho các ứng dụng GTK (như Files, Settings)
SCALE=$(echo "scale=2; $DPI / 96" | bc)
gsettings set org.gnome.desktop.interface text-scaling-factor $SCALE

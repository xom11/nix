#!/bin/bash

# Usage: ./set-dpi.sh [scale]
# Scale options: 1 | 1.25 | 1.5 | 2
# echo "Xft.dpi: $DPI" | xrdb -merge

BASE_DPI=96

set_dpi() {
    local scale=$1
    local dpi

    case "$scale" in
        1)    dpi=96  ;;
        1.25) dpi=120 ;;
        1.5)  dpi=144 ;;
        2)    dpi=192 ;;
        *)
            echo "❌ Invalid scale: $scale"
            echo "   Use one of: 1 | 1.25 | 1.5 | 2"
            exit 1
            ;;
    esac

    echo "🖥️  Scale: ${scale}x → DPI: $dpi"
    echo "Xft.dpi: $dpi" | xrdb -merge
    echo "✅ DPI set to $dpi"
}

if [ -z "$1" ]; then
    echo "Choose scale:"
    echo "  1)    1x   → 96 DPI"
    echo "  2)    1.25x → 120 DPI"
    echo "  3)    1.5x → 144 DPI"
    echo "  4)    2x   → 192 DPI"
    read -rp "Enter scale (1 / 1.25 / 1.5 / 2): " scale
    set_dpi "$scale"
else
    set_dpi "$1"
fi

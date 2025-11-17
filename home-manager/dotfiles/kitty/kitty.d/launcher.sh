#!/bin/bash

TITLE=$1
CMD="${@:2}"

kitty @ focus-tab --match title:"$TITLE" || kitty @ launch --type=tab --title="$TITLE" -- $CMD

# path
path+=(/opt/homebrew/opt/postgresql@18/bin)

# alias
alias copy='pbcopy'


# Function to set macOS desktop wallpaper.
wp() {
    if [ -z "$1" ]; then
        echo "Error: Please provide the image file path. (Example: wp ~/Desktop/image.jpg or wp ./image.jpg)"
        return 1
    fi

    local absolute_path=$(realpath "$1" 2>/dev/null)

    if [ -z "$absolute_path" ]; then
        echo "Error: Image file not found or path is invalid: $1"
        return 1
    fi

    /usr/bin/osascript -e "tell application \"System Events\" to set picture of every desktop to POSIX file \"$absolute_path\""

    echo "✅ Successfully set wallpaper to: $absolute_path"
}


install_pwa() {
  local apps=(
    # "https://web.telegram.org"
    "https://mail.google.com"
    "https://discord.com/app"
    "https://www.youtube.com"
    "https://gemini.google.com"
    "https://www.messenger.com"
    "https://keep.google.com"
    # "https://www.notion.so/"
    "https://chat.deepseek.com/"
    "https://claude.ai/new"
  )

  open "${apps[@]}"
}

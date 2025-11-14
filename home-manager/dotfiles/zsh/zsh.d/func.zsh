y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# t() {
#     if [ -z "$1" ]; then
#         SESSION_NAME="0"
#     else
#         SESSION_NAME="$1"
#     fi
#
#     if [ -z "$TMUX" ]; then
#         tmux attach -t "$SESSION_NAME" || tmux new -s "$SESSION_NAME"
#     else
#         tmux new-window -n "$SESSION_NAME"
#     fi
# }

gu() {
  if [ -z "$1" ]; then
    commit_msg="update"
  else
    commit_msg="$@" 
  fi

  git pull && \
  git add . && \
  git commit -m "$commit_msg" && \
  git push
}

gs1(){
    FILE=$1
    if [ -z "$FILE" ]; then
        echo "Lỗi: Vui lòng cung cấp tên tệp (ví dụ: gs ten_file.txt)"
        return 1
    fi
    git add $FILE
    git checkout -b $FILE -q 
    git commit -m "Fix typos in $FILE"
    git push -u origin $FILE

    gh pr create --title "docs: fix typos in $FILE" --body "Contribution by Gittensor, learn more at https://gittensor.io/"
    git switch main -q || git switch master -q || git switch dev -q || git switch develop -q||git switch test -q ||  echo "No main branch found"
}

gs() {
    ALGO=$1
    git checkout -b $ALGO -q 
    git commit -m "Add algorithm $ALGO"
    git push -u origin $ALGO

    PR_BODY="Contribution by Gittensor, learn more at https://gittensor.io/"

    gh pr create \
        --title "feat: add method $ALGO" \
        --body "$PR_BODY"
    git switch main -q || git switch master -q || git switch dev -q || git switch develop -q|| git switch test -q || echo "No main branch found"
}
gx() {
    if ! git diff --cached --exit-code; then
        gh repo fork --remote 
        UPSTREAM_REPO=$(git remote get-url upstream | sed -E 's/.*github.com[:/]([^/]+\/[^/]+)(\.git)?$/\1/' | sed 's/\.git$//')
        gh repo set-default $UPSTREAM_REPO

        BRANCH="Fix/typos/$(date +%Y%m%d%H%M%S)"
        git checkout -b $BRANCH -q 
        git commit -m "Fix typos in some files"
        git push -u origin $BRANCH

        gh pr create --title "docs: fix typos in some files" --body "This PR fixes typos in the file file using codespell."
    fi
    REPO_DIR=$(pwd)
    cd ..
    rm -rf $REPO_DIR    
    cd "$(ls -d */ | head -n 1)"
    lazygit
}
alias cs="codespell -w **/*.(asm|bash|c|cc|cmake|cpp|cs|cxx|go|groovy|h|hh|hpp|hxx|ino|java|js|jsx|lua|php|ps1|py|r|rb|rs|s|scala|sh|sql|svelte|swift|ts|tsx|vue)"

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

_uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        _arguments '*:filename:_files -g "*.py"'
    else
        _uv "$@"
    fi
}
compdef _uv_run_mod uv

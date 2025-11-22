
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

        gh pr create --title "docs: fix typos in some files" --body "Contribution by Gittensor, learn more at https://gittensor.io/"
    fi
    REPO_DIR=$(pwd)
    cd ..
    rm -rf $REPO_DIR    
    cd "$(ls -d */ | head -n 1)"
    lazygit
}
alias cs="codespell -w . --skip='*.txt,*.md,*.json,*.yaml,*.yml,*.csv,*.png,*.jpg,*.jpeg,*.gif,*.svg,*.lock'"


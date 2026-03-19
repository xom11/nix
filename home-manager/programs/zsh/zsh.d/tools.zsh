# PART: python
export PYTHONPATH=$(pwd)
if command -v micromamba &>/dev/null; then
  eval "$(micromamba shell hook --shell zsh)"
fi

# PART: wt (worktrunks)
if command -v wt &>/dev/null; then
  eval "$(command wt config shell init zsh)"
fi

# PART: pm2
if command -v pm2 &>/dev/null; then
  source <(pm2 completion)
fi

# PART: cloudflare
if command -v cloudflared &>/dev/null; then
  source <(cloudflared completion zsh)
fi


export PYTHONPATH=$(pwd)
if command -v micromamba &>/dev/null; then
  eval "$(micromamba shell hook --shell zsh)"
fi

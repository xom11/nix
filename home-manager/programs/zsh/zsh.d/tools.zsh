# PART: python
export PYTHONPATH=$(pwd)
if command -v micromamba &>/dev/null; then
  # nixpkgs boc micromamba bang makeWrapper, nen binary that ten `.mamba-wrapped`.
  # micromamba tu dinh vi chinh no qua /proc/self/exe -- KHONG phai argv[0], du
  # wrapper co `exec -a "$0"` -- roi nhung duong dan do vao hook va kiem basename
  # phai la mamba|micromamba. Truot thi hook sinh ra nhanh in loi thay vi dinh
  # nghia ham, va no hong AM THAM: `micromamba --version` van chay (goi thang
  # binary) trong khi `micromamba activate` chet voi "Shell not initialized".
  # Dat san MAMBA_EXE KHONG cuu duoc -- hook bo qua bien do, duong dan la literal
  # nhung cung luc sinh. Nen phai doi ten ngay trong output.
  # Tren mac (micromamba tu Homebrew) sed khong khop gi -- vo hai.
  MAMBA_EXE_REAL="$(command -v micromamba)"
  eval "$(micromamba shell hook --shell zsh | sed "s|/nix/store/[^\"']*/\.mamba-wrapped|${MAMBA_EXE_REAL}|g")"
  unset MAMBA_EXE_REAL
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
  source <(cloudflared completion zsh 2>/dev/null)
fi

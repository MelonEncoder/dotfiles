#!/usr/bin/env bash
set -euo pipefail

repo="$HOME/.local/share/dotfiles"

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      repo="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    *)
      echo "unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

config="$HOME/.config"
local_share="$HOME/.local/share"

echo "repo: $repo"
echo "config: $config"

mappings=(
  "$repo/configs/fcitx5|$config/fcitx5"
  "$repo/configs/gtk-3.0|$config/gtk-3.0"
  "$repo/configs/gtk-4.0|$config/gtk-4.0"
  "$repo/configs/hypr|$config/hypr"
  "$repo/configs/nvim|$config/nvim"
  "$repo/configs/qt6ct|$config/qt6ct"
  "$repo/configs/quickshell|$config/quickshell"
  "$repo/configs/zed|$config/zed"
  "$repo/home/.local/share/wallpapers|$local_share/wallpapers"
)

for mapping in "${mappings[@]}"; do
  src="${mapping%%|*}"
  dst="${mapping##*|}"
  parent="$(dirname "$dst")"
  mkdir -p "$parent"
  rm -rf "$dst"
  ln -s "$src" "$dst"
done

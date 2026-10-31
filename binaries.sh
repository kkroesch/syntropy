#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

echo "Aktualisiere eget..."
eget zyedidia/eget --to "$BIN_DIR"

echo "Installiere / aktualisiere CLI-Tools..."

# Core Tools & CLI-Utilities
eget nektos/act --to "$BIN_DIR"
eget sigoden/aichat --to "$BIN_DIR"
eget caddyserver/caddy --to "$BIN_DIR"
eget terrier9498/d2 --to "$BIN_DIR"
eget direnv/direnv --to "$BIN_DIR"
eget docker/compose --asset "docker-compose-linux-x86_64" --file docker-compose --to "$BIN_DIR"
eget naggie/dstask --to "$BIN_DIR"
eget duckdb/duckdb --to "$BIN_DIR"
eget muesli/duf --to "$BIN_DIR"
eget eza-community/eza --to "$BIN_DIR"
eget sharkdp/fd --to "$BIN_DIR"
eget junegunn/fzf --to "$BIN_DIR"
eget cli/cli --file gh --to "$BIN_DIR"
eget charmbracelet/glow --to "$BIN_DIR"
eget gopasspw/gopass --to "$BIN_DIR"
eget gohugoio/hugo --to "$BIN_DIR"
eget helix-editor/helix --file hx --to "$BIN_DIR"
eget casey/just --to "$BIN_DIR"
eget jesseduffield/lazygit --to "$BIN_DIR"
eget lsd-rs/lsd --to "$BIN_DIR"
eget mitsuhiko/minijinja --file minijinja-cli --to "$BIN_DIR"
eget jgm/pandoc --file bin/pandoc --to "$BIN_DIR"
eget F1bonacc1/process-compose --to "$BIN_DIR"
eget rclone/rclone --file rclone --to "$BIN_DIR"
eget restic/restic --to "$BIN_DIR"
eget BurntSushi/ripgrep --file rg --to "$BIN_DIR"
eget getsops/sops --to "$BIN_DIR"
eget starship/starship --to "$BIN_DIR"
eget surrealdb/surrealdb --file surreal --to "$BIN_DIR"
eget syncthing/syncthing --file syncthing --to "$BIN_DIR"
eget tectonic-typesetting/tectonic --to "$BIN_DIR"
eget tsl0922/ttyd --to "$BIN_DIR"
eget typst/typst --to "$BIN_DIR"
eget Enter-tainer/typstyle --to "$BIN_DIR"
eget ducaale/xh --to "$BIN_DIR"
eget mikefarah/yq --to "$BIN_DIR"
eget yt-dlp/yt-dlp --to "$BIN_DIR"
eget zellij-org/zellij --to "$BIN_DIR"
eget getzola/zola --to "$BIN_DIR"
eget ajeetdsouza/zoxide --to "$BIN_DIR"

# Neovim AppImage
echo "Aktualisiere Neovim AppImage..."
eget neovim/neovim --asset "nvim-linux-x86_64.appimage" --file "nvim-linux-x86_64.appimage" --to "$BIN_DIR/nvim-linux-x86_64.appimage"
chmod +x "$BIN_DIR/nvim-linux-x86_64.appimage"

# Symlinks sicherstellen
ln -sf "$BIN_DIR/minijinja-cli" "$BIN_DIR/mjj"
ln -sf "$BIN_DIR/xh" "$BIN_DIR/xhs"
ln -sf "$BIN_DIR/nvim-linux-x86_64.appimage" "$BIN_DIR/nvim"

# UV & Python Toolchain
if command -v uv >/dev/null 2>&1; then
    echo "Aktualisiere uv und verwaltete Python-Tools..."
    uv self update || true
    uv tool upgrade --all
fi

echo "Alles erfolgreich aktualisiert!"
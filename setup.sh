#!/bin/sh
#
#   curl -fsSL https://kroesch.ch/setup | sh
#   curl -fsSL https://kroesch.ch/setup | sudo sh      (phase 1 + 2)
#
# POSIX sh only - runs under dash, ash/busybox, bash, zsh, ksh.
# No unzip dependency: fonts come as .tar.xz, dotfiles as .tar.gz.
#
# Env overrides:
#   USER_NAME=... INSTALL_ZED=1|0 DOTFILES_TAR_URL=... GITHUB_TOKEN=...
#
# The {} block ensures the script is fully downloaded before anything runs
# (protects against truncated/aborted connections).
{
set -eu

USER_NAME="${USER_NAME:-karsten}"
REMOTE_URL="${REMOTE_URL:-https://kroesch.ch/setup}"

NERD_FONT="${NERD_FONT:-JetBrainsMono}"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${NERD_FONT}.tar.xz"

FAILED_TOOLS=""

have()  { command -v "$1" >/dev/null 2>&1; }
say()   { printf '%s\n' "$*"; }
fail()  { FAILED_TOOLS="${FAILED_TOOLS}${FAILED_TOOLS:+ }$1"; say "❌ $1 failed"; }

IS_MAC=false
[ "$(uname -s)" = "Darwin" ] && IS_MAC=true

# Was this script started as a file, or piped into the shell?
SELF=""
case "${0:-}" in
    -sh|sh|-bash|bash|-dash|dash|-zsh|zsh|-ash|ash|"") SELF="" ;;
    *) [ -f "$0" ] && SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")" ;;
esac

# ==============================================================================
# PHASE 1: ROOT SETUP  (Linux only - on macOS the user already exists)
# ==============================================================================
if [ "$(id -u)" -eq 0 ] && [ "$IS_MAC" = false ]; then
    say "🚀 Phase 1: system-wide setup (root)"

    # git for dotter/repos, xz for the Nerd Font tarballs, gzip for eget
    if have apt-get; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq
        apt-get install -y --no-install-recommends \
            zsh curl ca-certificates tar xz-utils gzip git gcc sudo ansible fontconfig
    elif have dnf; then
        dnf install -y zsh curl ca-certificates tar xz gzip git gcc sudo ansible fontconfig
    elif have pacman; then
        pacman -Sy --noconfirm zsh curl ca-certificates tar xz gzip git gcc sudo ansible fontconfig
    elif have apk; then
        apk add --no-cache zsh curl ca-certificates tar xz gzip git build-base sudo shadow fontconfig
    else
        say "⚠️ No known package manager found - please install base packages manually."
    fi

    ZSH_PATH="$(command -v zsh || echo /bin/zsh)"
    # Login shells must be listed in /etc/shells, otherwise chsh refuses
    if [ -f /etc/shells ] && ! grep -qxF "$ZSH_PATH" /etc/shells; then
        printf '%s\n' "$ZSH_PATH" >> /etc/shells
    fi

    if id "$USER_NAME" >/dev/null 2>&1; then
        say "ℹ️ User '$USER_NAME' already exists."
        chsh -s "$ZSH_PATH" "$USER_NAME" || true
    else
        say "👤 Creating user '$USER_NAME'..."
        useradd -m -s "$ZSH_PATH" "$USER_NAME"
    fi

    usermod -aG wheel "$USER_NAME" 2>/dev/null || true
    usermod -aG sudo  "$USER_NAME" 2>/dev/null || true

    mkdir -p /etc/sudoers.d
    printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$USER_NAME" > "/etc/sudoers.d/$USER_NAME"
    chmod 0440 "/etc/sudoers.d/$USER_NAME"

    say "🔄 Handing over to phase 2 as '$USER_NAME'..."
    if [ -n "$SELF" ]; then
        chmod a+r "$SELF" 2>/dev/null || true
        exec su - "$USER_NAME" -c "sh '$SELF'"
    else
        exec su - "$USER_NAME" -c "curl -fsSL '$REMOTE_URL' | sh"
    fi
fi

if [ "$(id -u)" -eq 0 ]; then
    say "⚠️ Phase 2 is running as root - this is probably not what you want."
fi

# ==============================================================================
# PHASE 2: USER SETUP
# ==============================================================================
say "🚀 Phase 2: user tools ($(id -un))"

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
PATH="$LOCAL_BIN:$PATH"
export PATH

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT INT TERM

for req in curl tar; do
    have "$req" || { say "💥 '$req' is missing - nothing works without it."; exit 1; }
done

# ---------------------------------------------------------
# 1. eget
# ---------------------------------------------------------
if have eget; then
    say "✅ eget is already installed."
else
    say "📥 Installing eget..."
    (cd "$LOCAL_BIN" && curl -fsSL https://zyedidia.github.io/eget.sh | sh) </dev/null \
        || fail eget
fi

# ---------------------------------------------------------
# 2. Installer scripts
# ---------------------------------------------------------
say "📥 Installing starship..."
curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$LOCAL_BIN" </dev/null \
    || fail starship

say "📥 Installing uv..."
curl -fsSL https://astral.sh/uv/install.sh | sh </dev/null || fail uv

# Zed only with a graphical session (or forced via INSTALL_ZED=1)
INSTALL_ZED="${INSTALL_ZED:-auto}"
if [ "$INSTALL_ZED" = auto ]; then
    if [ "$IS_MAC" = true ] || [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
        INSTALL_ZED=1
    else
        INSTALL_ZED=0
    fi
fi
if [ "$INSTALL_ZED" = 1 ]; then
    say "📥 Installing Zed..."
    curl -fsSL https://zed.dev/install.sh | sh </dev/null || fail zed
else
    say "⏭️ Skipping Zed (no graphical session; set INSTALL_ZED=1 to force)."
fi

# ---------------------------------------------------------
# 3. Nerd Font  (tar.xz instead of zip -> no unzip needed)
# ---------------------------------------------------------
FONT_DIR="$HOME/.local/share/fonts"
[ "$IS_MAC" = true ] && FONT_DIR="$HOME/Library/Fonts"

if ls "$FONT_DIR"/*"$NERD_FONT"* >/dev/null 2>&1; then
    say "✅ $NERD_FONT Nerd Font is already installed."
else
    say "🔤 Installing $NERD_FONT Nerd Font..."
    mkdir -p "$FONT_DIR" "$TMP_ROOT/font"
    if curl -fsSL -o "$TMP_ROOT/font.tar.xz" "$FONT_URL" \
       && tar -xf "$TMP_ROOT/font.tar.xz" -C "$TMP_ROOT/font"; then
        find "$TMP_ROOT/font" -name '*.ttf' -exec cp {} "$FONT_DIR/" \;
        if [ "$IS_MAC" = false ] && have fc-cache; then
            fc-cache -f "$FONT_DIR" >/dev/null
        fi
        say "✅ $NERD_FONT Nerd Font installed."
    else
        fail "$NERD_FONT"
        say "   (tar needs xz support: 'xz-utils' on Debian/Ubuntu, 'xz' on Fedora)"
    fi
    rm -rf "$TMP_ROOT/font" "$TMP_ROOT/font.tar.xz"
fi

# ---------------------------------------------------------
# 4. Tools via eget
#    Format: <repo> [extra eget arguments]
#    Hint: set GITHUB_TOKEN, otherwise the API rate limit kicks in.
# ---------------------------------------------------------
if have eget; then
    say "📦 Installing tools via eget..."
    while IFS= read -r tool; do
        [ -n "$tool" ] || continue
        case "$tool" in \#*) continue ;; esac

        repo="${tool%% *}"
        name="${repo##*/}"
        printf '   %-12s ' "$name"

        # $tool is deliberately unquoted: the extra arguments must be word-split
        # shellcheck disable=SC2086
        if eget $tool --to "$LOCAL_BIN" >/dev/null 2>&1; then
            printf '✅\n'
        else
            printf '❌\n'
            FAILED_TOOLS="${FAILED_TOOLS}${FAILED_TOOLS:+ }$name"
        fi
    done <<'EGET_TOOLS'
ClementTsang/bottom --asset btm
caddyserver/caddy
SuperCuber/dotter
eza-community/eza
dundee/gdu
gohugoio/hugo
helix-editor/helix --asset hx
casey/just
neovim/neovim --asset nvim
jgm/pandoc
BurntSushi/ripgrep --asset rg
tectonic-typesetting/tectonic
typst/typst
direnv/direnv
EGET_TOOLS
else
    say "⏭️ eget is missing - skipping the eget tools."
    fail eget-tools
fi

systemctl --user enable --now ssh-agent.service

# ---------------------------------------------------------
# 5. Dotfiles 
# ---------------------------------------------------------





# ==============================================================================
# SUMMARY
# ==============================================================================
say ""
if [ -z "$FAILED_TOOLS" ]; then
    say "🎉 Done - everything installed."
else
    say "🎉 Done, but the following components failed:"
    for f in $FAILED_TOOLS; do
        say "  - $f"
    done
fi
say "💡 Start a new shell or run 'exec zsh' to apply all changes."
say "💡 If not done already: add \$HOME/.local/bin to your PATH."

exit 0
}

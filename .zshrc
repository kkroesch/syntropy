# =============================================================================
# 1. Basics & History (Ersatz für OhMyZSH Defaults)
# =============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt append_history
setopt extended_history
setopt hist_ignore_dups
setopt share_history

unsetopt BEEP
unsetopt CORRECT

HISTIGNORE="history:fc:ls:la:cd:"
HISTORY_IGNORE="(history|ls|cd|fc|la|pwd|exit)"

# =============================================================================
# 2. Pfade & Environment
# =============================================================================
path+=("$HOME/.libshell" "$HOME/.local/bin")
fpath=( ~/.zfunc "${fpath[@]}" )
cdpath+=(~/Projects)

export GPG_TTY=$(tty)

# =============================================================================
# 3. Aliases, Plugins & Funktionen
# =============================================================================
source ~/.alias

# Lade die Git-Aliases von OhMyZSH als Standalone-Datei (siehe unten)
[ -f ~/.config/zsh/git.plugin.zsh ] && source ~/.config/zsh/git.plugin.zsh


export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent.socket"

autoload -U zmv

# Sudo Plugin Ersatz (Esc-Esc)
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && LBUFFER="sudo $LBUFFER"
}
zle -N sudo-command-line
bindkey '\e\e' sudo-command-line

# Key Bindings
bindkey -e
bindkey '^b' backward-word
bindkey '^f' forward-word
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Ctrl-W: Wort rückwärts löschen
bindkey '^W' backward-kill-word
# Zsh soll bei Slashes und Bindestrichen stoppen (Bash-Verhalten)
export WORDCHARS="${WORDCHARS:s#/#}"
export WORDCHARS="${WORDCHARS:s#\.#}"
export WORDCHARS="${WORDCHARS:s#-#}"

# Alt-Backspace (oder ESC gefolgt von Backspace)
bindkey '^[^?' backward-kill-word
bindkey '^[^H' backward-kill-word

# =============================================================================
# 4. Tools & Navigation
# =============================================================================

# FZF
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
source <(fzf --zsh)

# =============================================================================
# 5. Completions & Prompt (Starship)
# =============================================================================
autoload -Uz compinit
compinit
# Tab-Completion: Case-insensitive (Gross-/Kleinschreibung ignorieren)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

eval "$(starship init zsh)"

eval "$(direnv hook zsh)"

eval "$(zoxide init zsh)"

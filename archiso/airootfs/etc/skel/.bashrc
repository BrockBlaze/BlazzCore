# BlazzCore .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History settings
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend

# Aliases — navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Aliases — listing
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lAh --color=auto'
alias l='ls -CF --color=auto'

# Aliases — safety
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'

# Aliases — pacman
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias search='pacman -Ss'
alias remove='sudo pacman -Rns'
alias orphans='pacman -Qtdq'

# Use bat for cat if available (better syntax highlighting)
command -v bat &>/dev/null && alias cat='bat --style=plain'

# cd then list in one step
cl() { cd "$@" && ls -lh --color=auto; }

# Extract any archive format
extract() {
    if [[ -z "$1" ]]; then echo "Usage: extract <file>"; return 1; fi
    if [[ ! -f "$1" ]]; then echo "File not found: $1"; return 1; fi
    case "$1" in
        *.tar.bz2)   tar xjf "$1"           ;;
        *.tar.gz)    tar xzf "$1"           ;;
        *.tar.xz)    tar xJf "$1"           ;;
        *.tar.zst)   tar --zstd -xf "$1"    ;;
        *.tar)       tar xf "$1"            ;;
        *.bz2)       bunzip2 "$1"           ;;
        *.gz)        gunzip "$1"            ;;
        *.zip)       unzip "$1"             ;;
        *.7z)        7z x "$1"              ;;
        *.rar)       unrar x "$1"           ;;
        *.xz)        xz -d "$1"             ;;
        *.zst)       zstd -d "$1"           ;;
        *)           echo "Don't know how to extract: $1" ;;
    esac
}

# Enable bash completion
[[ -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

# fzf: fuzzy Ctrl+R history search and Ctrl+T file finder
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=bg+:#1a1a2e,hl:#8080c8,fg+:#e0e0f0,hl+:#8080c8'
fi

# bat as man pager (syntax-highlighted man pages)
command -v bat &>/dev/null && export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Default editor
export EDITOR=nano
export VISUAL=nano

# Starship prompt
eval "$(starship init bash)"

# Show system info only on the first terminal of each login session
_FF_FLAG="${XDG_RUNTIME_DIR:-/tmp}/blazzcore_ff_shown"
if command -v fastfetch &>/dev/null && [[ ! -f "$_FF_FLAG" ]]; then
    touch "$_FF_FLAG"
    fastfetch
fi
unset _FF_FLAG

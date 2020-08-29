###############################################################################
### Misc

export EDITOR="vim"
export HOSTNAME="$(hostname -s)"
export MOSH_SERVER_NETWORK_TMOUT=259200
export LPASS_AGENT_TIMEOUT=64800

typeset -U path

###############################################################################
### Clojure

# Lein
export LEIN_FAST_TRAMPOLINE=y

# Boot
export BOOT_EMIT_TARGET=no
export BOOT_JVM_OPTION="-client -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -XX:+UseConcMarkSweepGC -Xverify:none"

###############################################################################
### Direnv

if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

###############################################################################
### Nix

if [[ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
    . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

###############################################################################
### Node

export NPM_PACKAGES="$HOME/.npm-packages"
if [[ -e "$NPM_PACKAGES" ]]; then
    path=($NPM_PACKAGES/bin $path)
fi

###############################################################################
### Path

if [[ -e ~/.local/bin ]]; then
    path=(~/.local/bin $path)
fi

if [[ -e ~/Scripts ]]; then
    path=(~/Scripts $path)
fi

###############################################################################
### Private

if [[ -e ~/.zshenv-private ]]; then
    source ~/.zshenv-private
fi

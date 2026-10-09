# Linux-only environment. Sourced by env.sh. Works on two kinds of box:
#
#  Chef-managed (DDG devbox): Chef owns ~/.bashrc and already provides version-manager shims
#    (pyenv, nodenv, goenv), bash-completion, a direnv hook and aliases (gc, gs, tn, ta, ll...).
#    Entry point is ~/.ddg/bashrc, which Chef's ~/.bashrc sources last.
#  Personal: nothing is provided, so this config supplies the equivalents itself.
#    Entry point is ~/.bashrc. Tools come from Homebrew, using the same Brewfile as the Mac.
#
# The shared files mostly don't check for Chef. They check whether each thing is
# already there (alias defined, hook installed, shim on PATH), so nothing is added twice.
# DOTFILES_CHEF is only for the few places that can't be detected that way (yadm bootstrap).

if [ -d /etc/chef ] || [ -f "$HOME/.ddg_aliases" ]; then
  export DOTFILES_CHEF=1
else
  unset DOTFILES_CHEF
fi

# Homebrew on Linux (personal boxes). Static equivalent of `brew shellenv`.
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar" HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
  path_prepend "$HOMEBREW_PREFIX/sbin"
  path_prepend "$HOMEBREW_PREFIX/bin"
  export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
  export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
fi

# Ubuntu's apt packages use different names for fd and bat
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then alias fd=fdfind; fi
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then alias bat=batcat; fi

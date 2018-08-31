# -------------------------- oh-my-zsh config -------------------------------- #

export ZSH="$HOME/.dotfiles/zsh"
export OH_MY_ZSH="$ZSH/plugins/oh-my-zsh"

ZSH_THEME="refined"                 # prompt theme
DISABLE_AUTO_TITLE="true"           # disable auto-setting terminal title
COMPLETION_WAITING_DOTS="true"      # red dots whilst waiting for completion

# oh-my-zsh plugin list
plugins=(
  bundler
  brew
  last-working-dir
  osx
  rbenv
  ruby
  fasd
  fancy-ctrl-z
  zsh-syntax-highlighting
)

autoload -U compinit

# source oh-my-zsh plugins
for plugin ($plugins); do
    fpath=($OH_MY_ZSH/plugins/$plugin $fpath)
done

compinit

source $OH_MY_ZSH/lib/history.zsh
source $OH_MY_ZSH/lib/key-bindings.zsh
source $OH_MY_ZSH/lib/completion.zsh

source $OH_MY_ZSH/themes/$ZSH_THEME.zsh-theme
source $ZSH/plugins/scm_breeze/scm_breeze.plugin.zsh
source $ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

# ---------------------------------------------------------------------------- #

# cd stack
pushd() {
  if [ $# -eq 0 ]; then
    DIR="$HOME"
  else
    DIR="$1"
  fi
  builtin pushd "$DIR" > /dev/null
  # dirs
}
pushd_builtin() {
  builtin pushd > /dev/null
  # dirs
}
popd() {
  builtin popd > /dev/null
  # dirs
}

alias cd='pushd'
alias back='popd'
alias flip='pushd_builtin'

# fasd
eval "$(fasd --init auto)"
alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias d='fasd -d'        # directory
alias f='fasd -f'        # file
alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection
alias z='fasd_cd -d'     # cd, same functionality as j in autojump
alias zz='fasd_cd -d -i' # cd with interactive selection
export _FASD_MAX=1000

setopt auto_cd           # cd has always been optional

# safety first
set -o noclobber         # Do not overwrite files via '>'
alias rm="rm -i"         # Prompt before removing files via rm
alias cp="cp -i"         # Prompt before overwriting files via cp
alias mv="mv -i"         # Prompt before overwriting files via mv
alias ls="ls -AFG"       # Display all files, include hidden ones
alias ll="ls -AFGl"

# fuck ups
# eval "$(thefuck --alias)"
alias please='sudo $(fc -ln -1)'

alias oldvim="/usr/bin/vim"
alias vim="/usr/local/bin/nvim"

export PATH="$PATH:$HOME/.rvm/bin"    # Add RVM to PATH for scripting
export EDITOR="/usr/local/bin/nvim"   # whole lotta gang shit
export VISUAL="/usr/local/bin/nvim"

# vim in zsh
set -o vi
bindkey "^[QA" up-line-or-beginning-search
bindkey "^[QB" down-line-or-beginning-search

# show when in normal mode
setopt PROMPT_SUBST
export KEYTIMEOUT=5
function zle-line-init zle-keymap-select {
  VI_MODE="%{$fg_bold[red]%} [% NORMAL]% %{$reset_color%}"
  VI_PROMPT="${${KEYMAP/vicmd/$VI_MODE}/(main|viins)/}"

  # right prompt style
  RPS1="$VI_PROMPT %{$fg_bold[yellow]%} %@ %{$reset_color%}"
  RPS2=RPS1

  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select


# visual
autoload -U colors && colors
export CLICOLOR=1
export LSCOLORS="gxBxhxDxfxhxhxhxhxcxcx"

# add python3 modules to path
export PATH="$PATH:$HOME/Library/Python/3.6/bin"

# OS X zen
alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias zen='defaults write com.apple.finder CreateDesktop false && defaults write NSGlobalDomain _HIHideMenuBar -bool true && killall Finder && killall SystemUIServer'
alias unzen='defaults write com.apple.finder CreateDesktop true && defaults write NSGlobalDomain _HIHideMenuBar -bool false && killall Finder && killall SystemUIServer'

# python virtual environment
# -- "workon" : switch environments
# -- "mkvirtualenv" : create new environment

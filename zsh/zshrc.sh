# ------------------------ oh-my-zsh core config ------------------------------ #

export ZSHRC="$DOTFILES/zsh/zshrc.sh"
export ZSH="$DOTFILES/zsh/plugins/oh-my-zsh"

ZSH_THEME="refined"                 # prompt theme
DISABLE_AUTO_TITLE="true"           # disable auto-setting terminal title
COMPLETION_WAITING_DOTS="true"      # red dots whilst waiting for completion

# oh-my-zsh plugin list
# https://github.com/ohmyzsh/ohmyzsh/blob/master/oh-my-zsh.sh
plugins=(
  bundler
  brew
  osx
  rbenv
  ruby
  fancy-ctrl-z
  git
)

autoload -U compaudit compinit
fpath=($ZSH/lib/functions $ZSH/lib/completion $fpath)
compinit

# source oh-my-zsh plugins
for plugin ($plugins); do
  fpath=($ZSH/plugins/$plugin $fpath)
done

source $ZSH/lib/completion.zsh
source $ZSH/lib/functions.zsh
source $ZSH/lib/history.zsh
source $ZSH/lib/key-bindings.zsh

source $ZSH/themes/$ZSH_THEME.zsh-theme

for plugin ($plugins); do
  if [ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]; then
    source $ZSH/plugins/$plugin/$plugin.plugin.zsh
  fi
done

# --------------------------- extensions ------------------------------------- #

source $DOTFILES/zsh/plugins/scm_breeze/scm_breeze.sh
source $DOTFILES/zsh/plugins/scm_breeze/scm_breeze.plugin.zsh

source $DOTFILES/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

# ---------------------------------------------------------------------------- #

# -------------------------- node setup -------------------------------------- #

export NVM_DIR="$DOTFILES/zsh/plugins/nvm"

# nvm slows shell init so defer nvm init until: npm, node, nvm, or a node-dependent command requires it
# (https://www.growingwiththeweb.com/2018/01/slow-nvm-init.html)
if [ -s "$NVM_DIR/nvm.sh" ] && [ ! "$(type -f __init_nvm)" = function ]; then
  # load autocomplete
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  # comb nvm dir for global commands or use defaults
  if [ "$(ls -A $NVM_DIR/versions 2> /dev/null)" ]; then
    declare -a __node_commands=(nvm `find -L $NVM_DIR/versions/*/*/bin -type f -exec basename {} \; | sort -u`)
  else
    declare -a __node_commands=('nvm' 'node' 'npm' 'yarn' 'gulp' 'grunt' 'webpack', 'indy')
  fi

  # prefix those commands with nvm init
  function __init_nvm {
    for cmd in "${__node_commands[@]}"; do unalias $cmd; done
    \. "$NVM_DIR"/nvm.sh
    unset __node_commands
    unset -f __init_nvm
  }
  for cmd in "${__node_commands[@]}"; do alias $cmd='__init_nvm && '$cmd; done;
fi

# ---------------------------------------------------------------------------- #

# -------------------------- python setup -------------------------------------- #

python3_user_scripts_dir="$(python3 -c 'import sysconfig as _; print(_.get_path("scripts","posix_user"))')"
if [[ ! "$PATH" =~ "$python3_user_scripts_dir" ]]; then
  export PATH="$PATH:$python3_user_scripts_dir"
fi

# ---------------------------------------------------------------------------- #

# cd stack
setopt AUTO_PUSHD
# optional cd
setopt AUTO_CD

# fasd
if [[ "$(command -v fasd)" ]]; then
  eval "$(fasd --init auto)"
  alias a='fasd -a'        # any
  alias s='fasd -si'       # show / search / select
  alias d='fasd -d'        # directory
  alias f='fasd -f'        # file
  alias sd='fasd -sid'     # interactive directory selection
  alias sf='fasd -sif'     # interactive file selection
  alias z='fasd_cd -d'     # cd, same functionality as j in autojump
  alias zz='fasd_cd -d -i' # cd with interactive selection
  alias v='f -e vim'       # open in (neo-)vim
  export _FASD_MAX=1000
fi

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

# the evolution of man - mandate npm init
local nvim_bin=$(command -v nvim)    # use nvim command path, will break if nvim is an alias already
alias vi="/usr/bin/vim"
alias vim="__init_nvm 2> /dev/null; $nvim_bin"

export PATH="$PATH:$HOME/.rvm/bin"    # Add RVM to PATH for scripting
export EDITOR="$nvim_bin"
export VISUAL="$nvim_bin"

# vim in zsh
set -o vi
bindkey "^[QA" up-line-or-beginning-search
bindkey "^[QB" down-line-or-beginning-search
autoload -Uz edit-command-line
bindkey -M vicmd 'V' edit-command-line

# show when in normal mode
setopt PROMPT_SUBST
OG_PROMPT="$PROMPT"
export KEYTIMEOUT=5
function zle-line-init zle-keymap-select {
  VI_MODE="%{$fg_bold[red]%} [% NORMAL]% %{$reset_color%}"
  VI_PROMPT="${${KEYMAP/vicmd/$VI_MODE}/(main|viins)/}"

  # right prompt style
  RPS1="$VI_PROMPT %{$fg_bold[yellow]%} %@ %{$reset_color%}"
  RPS2=RPS1

  zle reset-prompt
  zle -R
}
zle -N zle-line-init
zle -N zle-keymap-select

# extend prompt to reflect virtualenv if exists
function virtualenv_info {
  local virtalenv_basename
  if [[ -n "$VIRTUAL_ENV" ]]; then
    venv_basename="${VIRTUAL_ENV##*/}"
  else
    venv_basename=''
  fi
  [[ -n "$venv_basename" ]] && echo "($venv_basename) "
}
# hack for deactivate
function set_virtualenv_info {
  export PROMPT="%{$fg[green]%}$(virtualenv_info)%{$reset_color%}% $OG_PROMPT"
}

# redraw on time reset & resize
TMOUT=60
function TRAPALRM {
  zle && { zle reset-prompt; zle -R }
}
function TRAPWINCH {
  zle && { zle reset-prompt; zle -R }
}

# hook funcs
[[ -z $precmd_functions ]] && precmd_functions=()
precmd_functions=($precmd_functions set_virtualenv_info)

# visual
autoload -U colors && colors
export CLICOLOR=1
export LSCOLORS="gxBxhxDxfxhxhxhxhxcxcx"

# OS X zen
alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias zen='defaults write com.apple.finder CreateDesktop false && defaults write NSGlobalDomain _HIHideMenuBar -bool true && killall Finder && killall SystemUIServer'
alias unzen='defaults write com.apple.finder CreateDesktop true && defaults write NSGlobalDomain _HIHideMenuBar -bool false && killall Finder && killall SystemUIServer'

# python virtual environment
# -- "workon" : switch environments
# -- "mkvirtualenv" : create new environment

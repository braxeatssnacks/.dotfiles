#!/bin/bash

nvim_config_dir="$HOME/.config/nvim"
nvim_config_path="$nvim_config_dir/init.vim"
tmux_config_path="$HOME/.tmux.conf"
tmux_layouts_dir="$HOME/.tmuxinator"
vim_config_dir="$HOME/.vim"
vim_config_path="$HOME/.vimrc"
zsh_config_path="$HOME/.zshrc"
checks=(
  $nvim_config_path
  $vim_config_path
  $tmux_config_path
  $tmux_layouts_dir
  $zsh_config_path
  $vim_config_dir
  $nvim_config_dir
)

function error {
  local msg=$1
  local err_code=${2:-1}
  echo "$(tput setaf 1)[ERROR]: $msg $(tput sgr 0)"
  echo "$(tput setaf 3)Exiting...$(tput sgr 0)"
  exit 1
}

function abort {
  local msg=${abort_msg:-'Okay, see ya!'}
  echo "$(tput setaf 5)${msg}$(tput sgr 0)"
  exit
}

function yn_prompt {
  [[ "$#" -ne 1 ]] && { error "missing prompt message"; }
  local prompt="$(tput setaf 6)${1}$(tput sgr 0)"
  # message
  echo -n "$prompt $(tput setaf 3)($(tput setaf 2)y$(tput setaf 3)/$(tput setaf 1)n$(tput setaf 3))$(tput sgr 0) "
  local answer
  local old_stty_cfg=$(stty -g)
  stty raw -echo; answer=$(head -c 1); stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y"; then
    echo
    return 0
  else
    echo
    return 1
  fi
}

function install_package {
  local package=$1
  if [[ -x "$(command -v brew)" ]]; then
    # os x
    brew install $1
  elif [[ -x "$(command -v apt-get)" ]]; then
    # ubuntu
    apt-get install $1
  else
    # TODO: determine installer based on OS
    error  "Sorry, I can't determine default package manager! Please install $1 manually & run this script again."
  fi
}

function check_software {
  echo "Checking to see if $1 is installed..."
  if ! [[ -x "$(command -v $1)" ]]; then
    echo "$(tput setaf 2) + $(tput setaf 5)$1$(tput sgr 0) is $(tput bold)NOT$(tput sgr0) yet installed."
    yn_prompt "Would you like to install it?" && install_package $1
  else
    echo "$(tput setaf 2) + $(tput setaf 5)${1}$(tput sgr 0) is already installed"
  fi
}

function install_softwares {
  check_software zsh
  check_software tmux
  check_software vim
  check_software python
  check_software nvim
  check_software ruby
}

function check_shell {
  if [[ -z "${SHELL##*zsh*}" ]] ;then
    echo "Nice! Your default shell is already zsh."
  else
    echo "I notice that your default shell is not zsh. To get the full experience, you may want it to be."
    yn_prompt "Would you like to change it?" &&
      chsh -s $(which zsh) ||
      echo "Okay. I won't stop you, but you're missing out! You can always manually switch it later."
  fi
}

function handle_existing_config {
  if yn_prompt "Would you like to backup your current dotfiles?"; then
    # backup files
    echo "Safety first!"
    for path in "${checks[@]}"; do
      if [[ -L "$path" ]]; then
        # follow symlinks & backup the contents of resolved target
        resolved=$path
        while [[ -L "$resolved" ]]; do
          dir="$(cd -P $(dirname "$resolved") && pwd)"
          resolved="$(readlink "$resolved")"
          # account for relative symlinks
          [[ "$resolved" != /* ]] && source="$dir/$resolved"
        done
        cp -pR $resolved "${path}.backup" && echo "${path/#$HOME/~} (-> ${resolved/#$HOME/~}) -> ${path/#$HOME/~}.backup"
      elif [[ -e "$path" ]]; then
        cp -R $path "${path}.backup" && echo "${path/#$HOME/~} -> ${path/#$HOME/~}.backup"
      fi
    done
  fi
  # trash it all
  echo "Onwards and upwards!"
  for path in "${checks[@]}"; do
    if [[ -e "$path" ]]; then
      rm -rf "$path" && echo " $(tput setaf 1)x$(tput sgr 0) ${path/#$HOME/~}"
    fi
  done
}

function link_dotfiles {
  ln -s "$HOME/.dotfiles/zsh/zshrc_manager.sh" "$HOME/.zshrc"
  ln -s "$HOME/.dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"
  ln -s "$HOME/.dotfiles/tmux/layouts" "$HOME/.tmuxinator"
  ln -s "$HOME/.dotfiles/vim/init.vim" "$HOME/.vimrc"
  # neovim -> vim
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.vim"
  ln -s "$HOME/.vimrc" "$HOME/.vim/init.vim"
  ln -s "$HOME/.vim" "$HOME/.config/nvim"
}

function main {
  echo "This script will attempt install and setup (neo-)vim, tmux & zsh on your device."
  if yn_prompt "Are you cool with that?"; then
    echo ""
    install_softwares
    echo

    echo "Now let's see about that shell of yours..."
    check_shell
    echo

    echo "This config replaces vim, neovim, tmux & zsh configuration files; if you have existing configuration, you may want to back it up."
    handle_existing_config
    echo

    echo "Now to glue everything up..."
    link_dotfiles

    echo "$(tput setaf 2)Success!$(tput sgr 0)"
    echo "Restart your shell to see the changes take effect. Welcome to the wave, my friend. 👩🏾‍💻👨🏾‍💻"
  else
    abort
  fi
}

main

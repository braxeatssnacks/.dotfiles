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
  if [[ "$bypass_yn_prompt" = true ]]; then
    return 0  # Always reply "yes"
  else
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
  fi
}

function check_os {
  uname_os=$(uname -s)
  if [[ $uname_os = "Darwin" ]]; then
    os=macos
    if [[ -x "$(command -v brew)" ]]; then
      pkg_mgr_install="brew install"
    else
      error "For MacOS, this deploy script requires Homebrew.  Please install Homebrew from https://brew.sh or install $package manually & run this script again."
    fi
  elif [[ $uname_os = "Linux" ]]; then
    os=linux
    if [[ -x "$(command -v zypper)" ]]; then
      pkg_mgr_install="sudo zypper install"   # openSUSE
    elif [[ -x "$(command -v apt-get)" ]]; then
      pkg_mgr_install="sudo apt-get install"  # Ubuntu, Debian, or equivalent
    elif [[ -x "$(command -v yum)" ]]; then
      pkg_mgr_install="sudo yum -y install"   # Red Hat, Fedora, CentOS, Amazon
    else
      error "For Linux, this deploy script only supports zypper, yum, and apt-get package managers.  Please install $package manually & run this script again."
    fi
  fi
}

function install_package {
  local package=$1
  if [[ $os = "linux" ]]; then
    if [[ $package = "nvim" ]]; then
      package="neovim"
    elif [[ $package = "pip3" ]]; then
      package="python3-pip"
    fi
  fi

  # Install package using detected package manager:
  $pkg_mgr_install $package
}

function check_software {
  echo "Checking to see if $1 is installed..."
  if ! [[ -x "$(command -v $1)" ]]; then
    echo "$(tput setaf 2) + $(tput setaf 5)$1$(tput sgr 0) is $(tput bold)$(tput setaf 1)NOT$(tput sgr0) yet installed."
    yn_prompt "Would you like to install it?" && install_package $1
  else
    echo "$(tput setaf 2) + $(tput setaf 5)${1}$(tput sgr 0) is already installed"
  fi
}

function install_softwares {
  check_software zsh
  check_software tmux
  check_software vim
  check_software python3
  check_software nvim
  if [[ $os = "linux" ]]; then
    check_software pip3
    pip3 install --user --upgrade setuptools
  fi
  pip3 install --user --upgrade pynvim
  check_software ruby
  check_software fasd
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

function fix_permissions {
  # init submodules to get omz dirs
  (cd ~/.dotfiles && \
    git pull -q && \
    git submodule update --init --recursive -q)

  # prevent zsh compinit insecure directories errors
  chmod -R go-w "$HOME/.dotfiles/zsh/plugins/oh-my-zsh/plugins"
  chown -R "$(whoami)" "$HOME/.dotfiles/zsh/plugins/oh-my-zsh/plugins"
}

function main {
  check_os
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
    fix_permissions

    echo "$(tput setaf 2)Success!$(tput sgr 0)"
    echo "Restart your shell to see the changes take effect. Welcome to the wave, my friend. 👩🏾‍💻👨🏾‍💻"
  else
    abort
  fi
}

if [[ $1 = '--bypass-yn-prompt' ]]; then
  bypass_yn_prompt=true
fi

main

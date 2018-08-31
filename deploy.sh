#!/usr/bin/env bash
# s/o to @parth for the template

function prompt_install {
	echo -n "$1 is not installed. Would you like to install it? (y/n) " >&2
  old_stty_cfg=$(stty -g)
	stty raw -echo
	answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
	stty $old_stty_cfg && echo
	if echo "$answer" | grep -iq "^y"; then
    if [ -x "$(command -v brew)" ]; then       # os x
      brew install $1
    elif [ -x "$(command -v apt-get)" ]; then  # ubuntu
      apt-get install $1
    else
      echo "Cannot determine default package manager! Please install $1 manually & run this script again ..."
      # TODO suggest package manager based on os
    fi
  fi
}

function check_for_software {
  echo "Checking to see if $1 is installed ..."
  if ! [ -x "$(command -v $1)" ]; then
    prompt_install $1
  else
    echo "$1 is already installed"
  fi
}

function check_default_shell {
  if [ -z "${SHELL##*zsh*}" ] ;then
    echo "Default shell is zsh."
	else
		echo -n "Default shell is not zsh. Do you want to chsh -s \$(which zsh)? (y/n)"
		old_stty_cfg=$(stty -g)
		stty raw -echo
		answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
		stty $old_stty_cfg && echo
		if echo "$answer" | grep -iq "^y" ;then
			chsh -s $(which zsh)
		else
			echo "Warning: Your configuration won't work properly. zsh is required for deploy ..."
		fi
	fi
}

# let's get to it
echo "This script will check for zsh, (neo-)vim, & tmux installations, and attempt to install them if they do not exist ..."

echo "Can ya dig it sucka? (y/n)"
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ;then
	echo
else
	echo "Aborting, nothing was changed ..."
	exit 0
fi

check_for_software zsh
echo
check_for_software tmux
echo
check_for_software vim
echo
check_for_software python
echo
check_for_software nvim
echo

check_default_shell

echo
echo -n "Would you like to backup your current dotfiles? (y/n) "
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ;then
  # TODO: check if files exist
	mv ~/.zshrc ~/.zshrc.backup
	mv ~/.tmux.conf ~/.tmux.conf.backup
	mv ~/.vimrc ~/.vimrc.backup
  # TODO: neovim link
else
	echo -e "\nWho cares about old stuff right?"
  set +o noclobber
fi

# effective symbolic links -> TODO: real symbolic links
printf "source '$HOME/.dotfiles/zsh/zshrc_manager.sh'" > ~/.zshrc
printf "source-file $HOME/.dotfiles/tmux/tmux.conf" > ~/.tmux.conf
printf "so $HOME/.dotfiles/vim/init.vim" > ~/.vimrc

echo
echo "Please log out and log back in for default shell to be initialized."


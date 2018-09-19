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
      echo "Sorry, I can't determine default package manager! Please install $1 manually & run this script again."
      # TODO suggest package manager based on os
    fi
  fi
}

function check_for_software {
  echo "Checking to see if $1 is installed ..."
  if ! [ -x "$(command -v $1)" ]; then
    prompt_install $1
  else
    echo "$1 is already installed."
  fi
}

function check_default_shell {
  if [ -z "${SHELL##*zsh*}" ] ;then
    echo "Good looks - your default shell is zsh."
	else
		echo -n "I noticed that your default shell is not zsh. Do you want to chsh -s \$(which zsh)? (y/n)"
		old_stty_cfg=$(stty -g)
		stty raw -echo
		answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
		stty $old_stty_cfg && echo
		if echo "$answer" | grep -iq "^y" ;then
			chsh -s $(which zsh)
		else
			echo "Look man, I'm not going to tell you what to do or anything but it's unlikely your configuration will work properly without zsh."
		fi
	fi
}

# let's get to it
echo "Let's check for zsh, (neo-)vim, tmux(-inator), ruby, & python installations, and attempt to install them if they do not exist ..."

echo "Can ya dig it sucka? (y/n)"
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ;then
	echo
else
	echo "Aborting ..."
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
check_for_software ruby
gem install tmuxinator >> /dev/null 2>&1
echo

check_default_shell

echo
echo -n "Would you like to backup your current dotfiles? (y/n) "
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ;then
  echo
  echo "Safety first!"
  if [ -e ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.backup && echo "~/.zshrc -> ~/.zshrc.backup"
  fi
  if [ -e ~/.tumx.conf ]; then
    mv ~/.tmux.conf ~/.tmux.conf.backup && echo "~/.tmux.conf -> ~/.tmux.conf.backup"
  fi
  if [ -e ~/.tmux.conf ]; then
    mv ~/.vimrc ~/.vimrc.backup && echo "~/.vimrc -> ~/.vimrc.backup"
  fi
else
  echo
	echo -e "Onwards and upwards! Never back! I respect your recklessness. Let's hope we don't regret it..."
  rm -rf ~/.zshrc
  rm -rf ~/.tmux.conf
  rm -rf ~/.vimrc
  rm -rf ~/.vim/init.vim
  rm -rf ~/.config/nvim
  rm -rf ~/.tmuxinator
fi

ln -s "$HOME/.dotfiles/zsh/zshrc_manager.sh" "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -s "$HOME/.dotfiles/tmux/layouts" "$HOME/.tmuxinator"
ln -s "$HOME/.dotfiles/vim/init.vim" "$HOME/.vimrc"
# neovim -> vim
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.vim"
ln -s "$HOME/.vimrc" "$HOME/.vim/init.vim"
ln -s "$HOME/.vim" "$HOME/.config/nvim"

echo
echo "Looks like we're all set! Reinitialize your shell to see the changes!"


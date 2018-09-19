# Run tmux if exists
if command -v tmux>/dev/null; then
	[ -z $TMUX ] && exec tmux
else
	echo "tmux not installed. Run ./deploy to configure dependencies ..."
fi

# implicit update of submodules
(cd ~/.dotfiles && \
git pull -q && \
git submodule update --init --recursive -q)

DOTFILES="$HOME/.dotfiles"

source "$DOTFILES/zsh/zshrc.sh"
# conditional set in tmux layout
if [ -n $WORK ]; then
  source "$DOTFILES/zsh/work_aliases.sh"
fi

source "$DOTFILES/tmux/tmuxinator/bin/tmuxinator.zsh"

export DOTFILES="$HOME/.dotfiles"

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

source "$DOTFILES/zsh/zshrc.sh"
source "$DOTFILES/zsh/aliases.sh"

source "$DOTFILES/tmux/tmuxinator/completion/tmuxinator.zsh"

# Run tmux if exists
# if command -v tmux>/dev/null; then
# 	[ -z $TMUX ] && exec tmux
# else
# 	echo "tmux not installed. Run ./deploy to configure dependencies ..."
# fi

# implicit update of submodules
(cd ~/.dotfiles && \
git pull -q && \
git submodule update --init --recursive -q)

source ~/.dotfiles/zsh/zshrc.sh
# TODO: env conditional
source ~/.dotfiles/zsh/work_aliases.sh

export DOTFILES="$HOME/.dotfiles"

# Run tmux if exists
if command -v tmux>/dev/null; then
  # attempt to reconnect to existing session or create new
  if test -z "$TMUX"; then
    session_num=$(
    tmux list-sessions  |
      grep -v attached 	|
      grep -oE '^\d+:' 	|
      grep -oE '^\d+' 	|
      head -1
    )
    if test $session_num; then exec tmux attach -t $session_num; else exec tmux; fi
  fi
else
  echo "tmux not installed. Run ${DOTFILES/#$HOME/~}/deploy.sh to configure dependencies..."
fi

# implicit update of submodules
(cd ~/.dotfiles && \
  git pull -q && \
  git submodule update --init --recursive -q)

source "$DOTFILES/zsh/zshrc.sh"
source "$DOTFILES/zsh/ext.sh"

source "$DOTFILES/tmux/tmuxinator/completion/tmuxinator.zsh"

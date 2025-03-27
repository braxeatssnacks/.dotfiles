export DOTFILES="$HOME/.dotfiles"
export XDG_CONFIG_HOME="$HOME/.config"

# Run tmux if exists
if command -v tmux>/dev/null; then
  # attempt to reconnect to existing session or create new
  if test -z "$TMUX"; then
    session_name=$(
    tmux list-sessions      |
      grep -v attached      |
      grep -oE '^(\w|\s)+:' |
      head -1
    )
    # default grep has no regex lookahead; prune colon from "$session_name"
    if test $session_name; then exec tmux attach -t ${session_name: : -1}; else exec tmux; fi
  fi
else
  echo "tmux not installed. Run ${DOTFILES/#$HOME/~}/deploy.sh to configure dependencies..."
fi

# implicit update of submodules if on master branch & no unstaged changes
if [[ "$(git -C $DOTFILES symbolic-ref HEAD | sed -e 's/^refs\/heads\///')" != 'master' ]]; then
  [[ -v "$DEBUG" ]] && echo "On non-master .dotfiles branch. Skipping updates..."
elif [[ -n "$(git -C $DOTFILES status --porcelain)" ]]; then
  [[ -v "$DEBUG" ]] && echo "Unstaged .dotfiles changes detected. Skipping updates..."
else
  [[ -v "$DEBUG" ]] && echo "Pulling down latest configuration..."
  git pull -q
  git submodule update --init --recursive -q
fi

source "$DOTFILES/zsh/zshrc.sh"
source "$DOTFILES/zsh/ext.sh"

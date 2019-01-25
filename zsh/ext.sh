# leverage conditional `source` logic here (maybe via tmux layout `pre_window` ENV variable)
# if [ -n $WORK ]; then
#   source "$DOTFILES/zsh/ext/work.sh"
# fi

# default behavior load everything
for extension in $DOTFILES/zsh/ext/*; do
  source "$extension"
done

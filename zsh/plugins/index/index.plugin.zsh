# REPOSITORY INDEX
function c {
  # allow configuration via GIT_REPO_DIR, set to ~/Projects by default
  GIT_REPO_DIR=${GIT_REPO_DIR:-"${HOME}/Projects"}
  local subdir
  if [[ "$1" == "" ]]; then
    subdir=""
  else
    subdir="$(/bin/ls "$GIT_REPO_DIR" | grep "$1" | head -n 1)"
  fi
  cd "$GIT_REPO_DIR/$subdir"
}

# complete with "~/Projects" prefix
compctl -/ -W "$GIT_REPO_DIR" c


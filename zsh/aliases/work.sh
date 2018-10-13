# work specific config
# s/o to david
function nerd-dropkick {
  tmux send-keys -t 2 "npm run start-dev" Enter
  tmux send-keys -t 1 "npm run dev" Enter
}

echo-header () {
  blue=$(tput setaf 4)
  normal=$(tput sgr0)
  echo "\n${blue}--> $@ ${normal}\n"
}

discourse-header () {
    echo-header "connecting to nw_discourse_dev"
}

discourse-shell () {
    discourse-header
    docker exec -it nw_discourse_dev bash
}

discourse-sidekiq () {
    discourse-header
    docker exec -it nw_discourse_dev bash -c "cd /home/app && ./run.sh sidekiq -q critical,4 -q default,2 -q low"
}

discourse-console () {
    discourse-header
    docker exec -it nw_discourse_dev bash -c 'cd /home/app && ./run.sh rails c'
}

discourse-rake () {
    discourse-header
    docker exec -it nw_discourse_dev bash -c 'cd /home/app && ./run.sh rake "$@"'
}

discourse-run () {
    discourse-header
    docker exec -it nw_discourse_dev bash -c 'cd /home/app && ./run.sh rails r "$@"'
}

discourse-log () {
    discourse-header
    docker exec -it nw_discourse_dev tail -f /home/app/build/log/$1
}

alias discourse-rails-logs="discourse-log rails.out"
alias discourse-rails-errors="discourse-log rails.err"
alias discourse-nginx-access="discourse-log discourse-access.log"
alias discourse-nginx-errors="discourse-log discourse-error.log"

export AWS_PROFILE=nwdev

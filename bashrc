# Git branch
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ <\1>/'
}

# terminal formatting
export PS1="\n\[\e[m\]\[\e[1;34m\][\@]:\[\e[m\]\[\e[1;33m\]\$(parse_git_branch) \\[\e[m\]\[\e[1;32m\]\w\n\[\e[m\]\[\e[1;37m\]\u$ "

# ls
alias ll="ls -lrth"

# tmux
TERM=screen-256color
alias tns="tmux new -s"
alias ta="tmux attach"
alias tat="tmux attach -t"
alias tks="tmux kill-session -t"

# Custom bash prompt
# path : /etc/profile.d/bash-prompt.sh
export LANG=en_US.UTF8

if [[ $(id -u) -eq 0 ]]; then
    export PS1='\n\e[1;37m[\e[m\e[1;32m\u\e[m\e[1;33m@\e[m\e[1;35m\H\e[m:\e[4m$(pwd)\e[m\e[1;37m]\e[m\e[1;36m\e[m\n# '
else
    export PS1='\n\e[1;37m[\e[m\e[1;32m\u\e[m\e[1;33m@\e[m\e[1;35m\H\e[m:\e[4m$(pwd)\e[m\e[1;37m]\e[m\e[1;36m\e[m\n$ '
fi

export HISTTIMEFORMAT='[%F %T] '

# Other Modules ---------------------------------------------------------------
# used for setting work  related secrets
[ -f ~/.environment_dep.sh ] && source ~/.environment_dep.sh

# enable fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# some things to consider
# https://medium.com/mkdir-awesome/the-ultimate-guide-to-modularizing-bash-script-code-f4a4d53000c2
# https://medium.com/mkdir-awesome/a-shell-script-starter-for-small-to-large-projects-d9996f0cce83
# https://github.com/ko1nksm/getoptions

# used to for some utils and sane python defaults
export PYTHONSTARTUP=~/.pythonrc.py

# aliases ---------------------------------------------------------------------
alias zshrc='source ~/.zshrc'
alias ll='ls -alh'
alias la='ls -A'
alias dirs='dirs -v | head -10'
alias ...='cd ../..'
alias ....='cd ../../..'
alias clip='xclip -sel clip'

alias diskspace="du -S | sort -n -r | less"
alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"
alias S='sudo -E env PATH=$PATH'

alias weather='http -p b wttr.in/10018'  # requires httpie
alias install='sudo yum install -y'
alias pinstall='S pip install'
alias pyclean='find . -type d -name __pycache__ -exec rm -rf {} \;'
alias docker='S docker'
alias d='docker'
alias dc='S docker-compose'
alias systemctl='sudo systemctl'
alias t2h='tmux2html --bg 30,41,64 -o ~/current_window.html'
alias mt="multitail"

alias k="kubectl"
alias kag="kubectl get ing,services,deployment,pods --all-namespaces"
alias ks="kubectl --namespace=kube-system"

kl() {
    if [ -z $1 ]
    then
        $(kubectl get pods --all-namespaces | fzf --header-lines=1 | awk '{print "kubectl logs -n " $1 " " $2}')
    else
        local awk_cmd="{print \"kubectl logs -n ${1} \" \$1}"
        $(kubectl get pods -n $1 | fzf --header-lines=1 | awk $awk_cmd)
    fi
}

kd() {
    if [ -z $1 ]
    then
        $(kubectl get pods --all-namespaces | fzf --header-lines=1 | awk '{print "kubectl describe pod -n " $1 " " $2}')
    else
        local awk_cmd="{print \"kubectl describe pod -n ${1} \" \$1}"
        $(kubectl get pods -n $1 | fzf --header-lines=1 | awk $awk_cmd)
    fi
}

kash() {
    kubectl run remote-shell --image='abuckenheimer/py-eks:latest' -i -t --command sh || kubectl attach $(kubectl get pods -l 'run=remote-shell' -o 'jsonpath={.items[0].metadata.name}') -c remote-shell -i -t
}

hl() {
    kubectl $@ -l "app.kubernetes.io/instance=$(helm last)" --all-namespaces

}

hdl() {
    helm delete --purge $(helm last)
}

krb() {
    kubectl get rolebindings,clusterrolebindings \
        --all-namespaces  \
        -o custom-columns='KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,SERVICE_ACCOUNTS:subjects[?(@.kind=="ServiceAccount")].name'
}


# a more readable netstat
alias ntst="sudo netstat -tulpn"

# get cwd and environment for a specific process
cwdp () { sudo ls -l "/proc/$1/cwd" ;}
envp () { sudo cat "/proc/$1/environ" ;}

psg () { ps -ef | grep -v grep | grep "$@" ;}
F () { find . -type f -name $*;}

alias inside="docker run -it --rm --entrypoint=/bin/bash"
rmdock (){ docker rm $1 $(docker ps -a -q) }
rmldock (){ docker rm $(docker ps -alq) }
rmsince (){ docker rm $2 $(docker ps -q --filter=since=$1) }
rmidangling () { docker rmi $1 $(docker images -f "dangling=true" -q)}

# Functions -------------------------------------------------------------------
extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1    ;;
           *.tar.gz)    tar xvzf $1    ;;
           *.bz2)       bunzip2 $1     ;;
           *.rar)       unrar x $1     ;;
           *.gz)        gunzip $1      ;;
           *.tar)       tar xvf $1     ;;
           *.tbz2)      tar xvjf $1    ;;
           *.tgz)       tar xvzf $1    ;;
           *.zip)       unzip $1       ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
}


# AWS -------------------------------------------------------------------------
# ecr logs you out every now and again, login to a specific region in one step with this
ecr_login() {
    $(aws ecr get-login --region ${1:-$AWS_DEFAULT_REGION} | sed 's/-e none//g')
}

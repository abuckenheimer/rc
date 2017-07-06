# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git ruby bundler docker docker-compose git-prompt history jira postgres)


# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# uncomment for powerline
# . /usr/lib/anaconda3/lib/python3.4/site-packages/powerline/bindings/zsh/powerline.zsh
source ~/.environment_dep.sh

alias zshrc='source ~/.zshrc'
alias ll='ls -alh'
alias la='ls -A'
alias dirs='dirs -v | head -10'
alias ...='cd ../..'
alias ....='cd ../../..'
alias clip='xclip -sel clip'

alias diskspace="du -S | sort -n -r |more"
alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"
alias S='sudo -E env PATH=$PATH'
alias T='tail -f'

alias weather='http -p b wttr.in/10018'  # requires httpie
alias install='sudo yum install -y'
alias pinstall='S pip install'
alias pyclean='find . -type d -name __pycache__ -exec rm -rf {} \;'
alias docker='S docker'
alias d='docker'
alias dc='S docker-compose'
alias systemctl='sudo systemctl'
alias ipython='ipython --profile=buck'
alias t2h='tmux2html --bg 30,41,64 -o ~/current_window.html'
alias mt="multitail"

alias Kip="S iptables -L -t nat"
alias Kc="kubectl create -f"
alias Ks="kubectl stop"
alias Kg="kubectl get services,rc,pods"
alias Ke="kubectl exec"
alias Kl="kubectl logs"
alias KSc="kubectl --namespace=kube-system create -f"
alias KSs="kubectl --namespace=kube-system stop"
alias KSg="kubectl --namespace=kube-system get services,rc,pods"
alias KSe="kubectl --namespace=kube-system exec"
alias KSl="kubectl --namespace=kube-system logs"
# for using a second docker daemon (used to be a kubernetes thing)
alias dockerbs="sudo docker -H unix:///var/run/docker-bootstrap.sock"
# a more readable netstat
alias ntst="sudo netstat -tulpn"

# get cwd and environment for a specific process
cwdp () { sudo ls -l "/proc/$1/cwd" ;}
envp () { sudo cat "/proc/$1/environ" ;}

psg () { ps -ef | grep -v grep | grep "$@" ;}
F () { find . -type f -name $*;}

alias inside="docker run -it --rm --entrypoint=/bin/bash"
stopdock (){ docker stop $(docker ps -a -q) }
rmdock (){ docker rm $1 $(docker ps -a -q) }
rmldock (){ docker rm $(docker ps -alq) }
rmsince (){ docker rm $2 $(docker ps -q --filter=since=$1) }
rmidangling () { docker rmi $1 $(docker images -f "dangling=true" -q)}


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

localk () {
    docker run --net=host -d gcr.io/google_containers/etcd:2.0.12 /usr/local/bin/etcd --addr=127.0.0.1:4001 --bind-addr=0.0.0.0:4001 --data-dir=/var/etcd/data && \
    docker run \
        --volume=/:/rootfs:ro \
        --volume=/sys:/sys:ro \
        --volume=/dev:/dev \
        --volume=/var/lib/docker/:/var/lib/docker:ro \
        --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
        --volume=/var/run:/var/run:rw \
        --net=host \
        --privileged=true \
        -d \
        gcr.io/google_containers/hyperkube:v1.0.1 \
        /hyperkube kubelet --containerized --hostname-override="127.0.0.1" --address="0.0.0.0" --api-servers=http://localhost:8080 --config=/etc/kubernetes/manifests && \
    docker run -d --net=host --privileged gcr.io/google_containers/hyperkube:v1.0.1 /hyperkube proxy --master=http://127.0.0.1:8080 --v=2
}

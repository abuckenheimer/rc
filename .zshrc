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

# Other Modules ---------------------------------------------------------------
# used for setting work related secrets
[ -f ~/.environment_dep.sh ] && source ~/.environment_dep.sh

# enable fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# used to for some utils and sane python defaults
[ -f ~/.pythonrc.py ] && export PYTHONSTARTUP=~/.pythonrc.py

source ~/.bashrc
export BYOBU_PYTHON=/usr/bin/python3

# aliases ---------------------------------------------------------------------
alias zshrc='source ~/.zshrc'
alias ll='ls -alh'
alias la='ls -A'
alias dirs='dirs -v | head -10'
alias ...='cd ../..'
alias ....='cd ../../..'
alias clip='xclip -sel clip'

# alias subl="/c/Program\ Files/Sublime\ Text\ 3/subl.exe"
# https://thorsten-hans.com/5-types-of-zsh-aliases#suffix-aliases
alias -s {md,py,html,csv,yml}=subl

finagle() {
  cat - > /c/Users/Buck/AppData/Local/Temp/bash_scratch
  subl -w /Users/Buck/AppData/Local/Temp/bash_scratch
  cat /c/Users/Buck/AppData/Local/Temp/bash_scratch
  rm /c/Users/Buck/AppData/Local/Temp/bash_scratch
}

pfinagle() {
  echo $PATH | tr ":" "\n" | finagle | tr "\n" ":"
}

alias diskspace="du -S | sort -n -r | less"
alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"
alias S='sudo -E env PATH=$PATH'

alias weather='http -p b wttr.in/10018'  # requires httpie
alias install='sudo yum install -y'
alias pinstall='S pip install'
alias pyclean="find . -type d -name __pycache__ | parallel -v 'rm -rf {}'"
alias d='docker'
alias dc='docker-compose'
alias systemctl='sudo systemctl'
alias t2h='tmux2html --bg 30,41,64 -o ~/current_window.html'
alias mt="multitail"


alias j='just'


# alias alias kubectl="/c/Program\ Files/Docker/Docker/resources/bin/kubectl.exe"
[ -f /c/Users/Buck/.kube/config ] && export KUBECONFIG="/c/Users/Buck/.kube/config"
alias k="kubectl"
alias kag="kubectl get ing,services,deployment,pods --all-namespaces"
# alias ks="kubectl --namespace=kube-system"

kapi() {
    kubectl api-resources | sk --header-lines=1 | awk '{print $1}'
}

kns() {
    kubectl get ns | sk --header-lines=1 | awk '{print $1}'
}

ks() {
    if [ -z $1 ]
    then
        export KSRC=$(kapi)
    else
        export KSRC=$1
    fi
    if [ -z $2 ]
    then
        local line=$(kubectl get $KSRC --all-namespaces --sort-by '{metadata.creationTimestamp}' | awk 'NR == 1; NR > 1 {print $0 | "tac"}' | sk --header-lines=1 --preview "kubectl describe $KSRC -n {1} {2}")
        export KNS=$(echo $line | awk '{print $1}')
        export KOBJ=$(echo $line | awk '{print $2}')
    else
        export KNS=$2
        export KOBJ=$(kubectl get $KSRC -n $KNS | sk --header-lines=1 | awk '{print $2}')
    fi
}

kl() {
    local params=""
    if [ "$1" = "-f" ]
    then
      local params="-f"
      shift 1
    fi
    ks pods $1
    local kpod=$(kubectl get pods -n $KNS $KOBJ -o jsonpath='{.spec.containers[*].name}' | tr " " "\n")
    if [ $(echo $kpod | wc -l) -ne 1 ]
    then
      kpod=$(echo $kpod | sk)
    fi
    # rargs?
    kubectl logs -n $KNS $KOBJ $kpod $params
}

kd() {
    ks $@
    kubectl describe $KSRC -n $KNS $KOBJ
}

kg() {
    ks $@
    kubectl get $KSRC -n $KNS $KOBJ -o yaml
}

kcc() {
    local context=$(kubectl config get-contexts | sk --header-lines=1 | awk '{print $1}')
    if [ "${context}" != '*' ]
    then
      kubectl config use-context  ${context}
    fi
}

kedit() {
    ks $@
    kubectl edit $KSRC -n $KNS $KOBJ
}

kinside() {
    ks pod $1
    kubectl exec -it -n $KNS $KOBJ bash
}

kpf() {
    ks svc $1
    local port=$(kubectl get svc $KOBJ -n $KNS -o jsonpath='{.spec.ports[*].port}' | tr " " "\n")
    if [ $(echo $port | wc -l) -ne 1 ]
    then
      port=$(echo $port | sk)
    fi
    kubectl port-forward svc/$KOBJ $port:$port -n $KNS
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

ae() {
  argo -n argo-events $@
}

atrims() {
  local ALABLE="${1:-Succeeded}"
  local TCUTOFF="${2:-30m}"
  local containers=$(argo list -l "workflows.argoproj.io/phase=$ALABLE" --older $TCUTOFF -n argo-events | tail -n +2 | awk '{print $1}')
  while [ ! -z "$containers" ]
  do
    parallel -n 4 'argo delete {} -n argo-events' ::: $(echo $containers)
    local containers=$(argo list -l "workflows.argoproj.io/phase=$ALABLE" --older $TCUTOFF -n argo-events | tail -n +2 | awk '{print $1}')
  done
}

awatch() {
  argo watch $(argo list -l 'workflows.argoproj.io/phase in (Pending, Running)' $@ | sk --header-lines=1 | awk '{print $1}') $@
}

aewatch() {
  argo watch $(argo list -l 'workflows.argoproj.io/phase in (Pending, Running)' -n argo-events | sk --header-lines=1 | awk '{print $1}') -n argo-events
}

alogs() {
  argo logs --no-color $(argo list $@ | sk --header-lines=1 --preview "argo logs --no-color --tail 40 {1} $@" | awk '{print $1}') $@
}

aelogs() {
  argo logs --no-color $(argo list -n argo-events | sk --header-lines=1 --preview "argo logs --no-color -n 40 {1} -n argo-events" | awk '{print $1}') -n argo-events $@
}

astop() {
  argo stop $(argo list -l 'workflows.argoproj.io/phase in (Pending, Running)' $@ | sk --header-lines=1 -m | awk '{print $1}') $@
}

aestop() {
  argo stop $(argo list -l 'workflows.argoproj.io/phase in (Pending, Running)' -n argo-events | sk --header-lines=1 -m | awk '{print $1}') -n argo-events
}


dimage() {
    docker images | sk --header-lines=1 -m | awk '{print $1":"$2}'
}

dlogs() {
    local container=$(docker ps -a | sk --header-lines=1 --preview "docker logs {1} --tail 20" | awk '{print $1}')
    if [ -n "$container" ]; then
      docker logs -f $container
    fi
}

afailed() {
    argo list -l 'workflows.argoproj.io/phase=Failed' | sk --header-lines=1 --preview "argo logs {1}" | awk '{print $1}'
}


# a more readable netstat
alias ntst="sudo netstat -tulpn"

# get cwd and environment for a specific process
cwdp () { sudo ls -l "/proc/$1/cwd" ;}
envp () { sudo cat "/proc/$1/environ" ;}

psg () { ps -ef | grep -v 'sk --header-lines=1' | sk --header-lines=1 $@ | awk '{print $2}' }
psk () { kill $(ps -ef | sk --header-lines=1 $@ | awk '{print $2}') }
pydump() { S py-spy record -d 20 -o dump.svg --pid $(psg -q "python") }
pytop() { S py-spy top --pid $(psg -q "python") }
F () { find . -type f -name $*;}

alias inside="docker run -it --rm --entrypoint=/bin/bash"
rmdock () { docker rm $(docker ps -a | sk --header-lines=1 -m | awk '{print $1}')}
# rmdock (){ docker rm $1 $(docker ps -a -q) }
rmldock (){ docker rm $(docker ps -alq) }
rmsince (){ docker rm $2 $(docker ps -q --filter=since=$1) }
rmidangling () { docker rmi $1 $(docker images -f "dangling=true" -q)}
# docker images --format "{{.Repository}}:{{.Tag}}"
rmidock () { docker rmi $(docker images | sk --header-lines=1 -m | awk '{print $1":"$2}')}

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

# replay () {
#   fc -rl -50 | sk -m | \
#     awk '{for(i=2;i<=NF;++i)printf $i""FS ; print ""}' | \
#     sed 's/$/ \&\& \\/' | \
#     head --bytes=-3 |
#     > /c/Users/Buck/AppData/Local/Temp/bash_scratch
#   subl -w /c/Users/Buck/AppData/Local/Temp/bash_scratch
#   cat /c/Users/Buck/AppData/Local/Temp/bash_scratch
#   rm /c/Users/Buck/AppData/Local/Temp/bash_scratch
# }


# AWS -------------------------------------------------------------------------
# ecr logs you out every now and again, login to a specific region in one step with this
ecr_login() {
    $(aws ecr get-login --region ${AWS_DEFAULT_REGION:-us-east-1} $@ | sed 's/-e none//g')
}

ec2i() {
    curl "https://ec2.shop?region=${1:-us-east-1}" 2> /dev/null | sk --header-lines=1 -m
}

aws_assume() {
    if [ -n "$creds" ]; then
        unset creds
        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_SESSION_TOKEN
    fi
    export creds=$(aws sts assume-role --role-arn ${1:-arn:aws:iam::786074923500:role/Labs-team} --role-session-name foobar)
    export AWS_ACCESS_KEY_ID=$(echo $creds | jq '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo $creds | jq '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo $creds | jq '.Credentials.SessionToken')
}

aws_profile() {
    if [ "$1" = "-u" ]; then
        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_SESSION_TOKEN
        return
    fi
    if [ -n "$1" ]; then
      local profile=$(sed -E 's/\[(.*)\]/\1/' < ~/.aws/credentials | grep $1)
    fi
    if [ ! -n "$profile" ]; then
      local profile=$(grep -E '^\[' ~/.aws/credentials | sed -E 's/\[(.*)\]/\1/' | sk)
    fi
    local acreds=$(grep $profile ~/.aws/credentials -A 2 | awk '{print $3}')
    export AWS_ACCESS_KEY_ID=$(echo $acreds | tail -n +2 | head -n 1)
    export AWS_SECRET_ACCESS_KEY=$(echo $acreds | tail -n +3 | head -n 1)
}

get_topic() {
    ~/go/bin/topicctl --cluster-config ${1:-cluster.yml} get topics --no-spinner 2>&1 \
      | sk --header-lines=5 --preview "~/go/bin/topicctl get offsets {2} --cluster-config ${1:-cluster.yml} --no-spinner 2>&1" \
      | awk '{print $1}'
}

# auto completes --------------------------------------------------------------
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/vault vault

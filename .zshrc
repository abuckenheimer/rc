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
plugins=(git bundler docker docker-compose history postgres)

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

# https://github.com/starship/starship
eval "$(starship init zsh)"
export STARSHIP_CONFIG="/c/dev/rc/starship.toml"

# Other Modules ---------------------------------------------------------------
# used for setting work related secrets
[ -f ~/.environment_dep.sh ] && source ~/.environment_dep.sh

# enable fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# enable mcfly
[ -f ~/.config/mcfly/init.zsh ] && source ~/.config/mcfly/init.zsh

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
alias kag="kubectl get ing,services,deployment,pods --all-namespaces -l '!workflows.argoproj.io/workflow'"
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
        local line=$(kubectl get $KSRC --all-namespaces --sort-by '{metadata.creationTimestamp}' | awk 'NR == 1; NR > 1 {print $0 | "tac"}' | sk --header-lines=1 --preview "kubectl describe $KSRC -n {1} {2} | tail -n 65")
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

ksnode() {
    kubectl get nodes -L node.kubernetes.io/instance-type | sk -m --header-lines=1 --preview 'kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName={1}' | awk '{print $1}'
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
    kubectl port-forward svc/$KOBJ ${EXTERNAL_PORT:-$port}:$port -n $KNS
}

kpfp() {
    ks pod $1
    local port=$(kubectl get pod $KOBJ -n $KNS -o jsonpath='{.spec.containers[*].ports[*].containerPort}' | tr " " "\n")
    if [ $(echo $port | wc -l) -ne 1 ]
    then
      port=$(echo $port | sk)
    fi
    kubectl port-forward pod/$KOBJ ${EXTERNAL_PORT:-$port}:$port -n $KNS
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

aswitch() {
  local ARGO_NAMESPACE=${1:?expected ARGO_NAMESPACE to be set}
  shift 1
  local COMMAND=${1:?expected at least one command to be set}
  shift 1
  case $COMMAND in
    selectg)
      argo list -n ${ARGO_NAMESPACE} $@ \
        | sk --header-lines=1 -m --preview "argo get {1} -n ${ARGO_NAMESPACE}" \
        | awk '{print $1}'
      ;;

    selectl)
      argo list -n ${ARGO_NAMESPACE} $@ \
        | sk --header-lines=1 -m --preview "argo logs --no-color --tail 40 {1} -n ${ARGO_NAMESPACE}" \
        | awk '{print $1}'
      ;;

    get)
      argo get -n ${ARGO_NAMESPACE} $(aswitch ${ARGO_NAMESPACE} selectg) $@
      ;;

    logs)
      argo logs --no-color -n ${ARGO_NAMESPACE} $(aswitch ${ARGO_NAMESPACE} selectl) $@
    ;;

    watch)
      argo watch \
        -n ${ARGO_NAMESPACE} \
        $(
          aswitch ${ARGO_NAMESPACE} selectg \
          -l 'workflows.argoproj.io/phase in (Pending, Running)'
        ) \
        $@
    ;;

    stop)
      parallel -n 4 "argo stop {} -n ${ARGO_NAMESPACE} $@" \
        ::: $(
          aswitch ${ARGO_NAMESPACE} selectg \
          -l 'workflows.argoproj.io/phase in (Pending, Running)'
        )
    ;;

    delete)
      parallel -n 4 "argo delete {} -n ${ARGO_NAMESPACE} $@" \
        ::: $(aswitch ${ARGO_NAMESPACE} selectg)
    ;;

    trim)
      local ALABLE="${1}"
      local TCUTOFF="${2:-30m}"
      local containers=$(
        argo list -l "workflows.argoproj.io/phase=$ALABLE" --older $TCUTOFF -n ${ARGO_NAMESPACE} \
          | tail -n +2 \
          | awk '{print $1}'
      )
      while [ ! -z "$containers" ]
      do
        parallel -n 4 "argo delete {} -n ${ARGO_NAMESPACE}" ::: $(echo $containers)
        local containers=$(
          argo list -l "workflows.argoproj.io/phase=$ALABLE" --older $TCUTOFF -n ${ARGO_NAMESPACE} \
            | tail -n +2 \
            | awk '{print $1}'
          )
      done
    ;;

    *)
    argo -n ${ARGO_NAMESPACE} $COMMAND $@
    ;;
  esac
}

ac() {
  aswitch carnegie $@
}

ae() {
  aswitch argo-events $@
}

pgconnect() {
  local conn=$(egrep -v '^#' ~/.pgpass | sk)
  local host=$(echo $conn | cut -d: -f1)
  local port=$(echo $conn | cut -d: -f2)
  local db=$(echo $conn | cut -d: -f3)
  local user=$(echo $conn | cut -d: -f4)
  [ "${port}" = '*' ] && local port='5432'
  [ "${user}" = '*' ] && local user='postgres'
  [ "${db}" = '*' ] && local db=$(psql -h $host -p $port -U $user postgres -l | sk --header-lines 3 | awk '{print $1}')
  if [ "${1}" = "--dry-run" ]
  then
    echo psql -h $host -p $port -U $user $db
  else
    psql -h $host -p $port -U $user $db
  fi
}

pguri() {
  local conn=$(egrep -v '^#' ~/.pgpass | sk)
  local host=$(echo $conn | cut -d: -f1)
  local port=$(echo $conn | cut -d: -f2)
  local db=$(echo $conn | cut -d: -f3)
  local user=$(echo $conn | cut -d: -f4)
  local pass=$(echo $conn | cut -d: -f5)
  [ "${port}" = '*' ] && local port='5432'
  [ "${user}" = '*' ] && local user='postgres'
  [ "${db}" = '*' ] && local db=$(psql -h $host -p $port -U $user postgres -l | sk --header-lines 3 | awk '{print $1}')

  echo "postgres://${user}:${pass}@${host}:${port}/${db}"
}

# atrims() {
#   local ALABLE="${1}"
#   local TCUTOFF="${2:-30m}"
#   local NAMESPACE="${2:-carnegie}"
#   local containers=$(argo list -l "workflows.argoproj.io/phase=$ALABLE" --older $TCUTOFF -n argo-events | tail -n +2 | awk '{print $1}')
#   while [ ! -z "$containers" ]
#   do
#     parallel -n 4 'argo delete {} -n argo-events' ::: $(echo $containers)
#     local containers=$(argo list -l "workflows.argoproj.io/phase=$ALABLE" --older $TCUTOFF -n argo-events | tail -n +2 | awk '{print $1}')
#   done
# }

# awatch() {
#   argo watch $(argo list -l 'workflows.argoproj.io/phase in (Pending, Running)' $@ | sk --header-lines=1 | awk '{print $1}') $@
# }

# aewatch() {
#   argo watch $(argo list -l 'workflows.argoproj.io/phase in (Pending, Running)' -n argo-events | sk --header-lines=1 | awk '{print $1}') -n argo-events
# }

# alogs() {
#   argo logs --no-color $(argo list $@ | sk --header-lines=1 --preview "argo logs --no-color --tail 40 {1} $@" | awk '{print $1}') $@
# }

# aelogs() {
#   argo logs --no-color $(argo list -n argo-events | sk --header-lines=1 --preview "argo logs --no-color -n 40 {1} -n argo-events" | awk '{print $1}') -n argo-events $@
# }

# astop() {
#   argo stop $(argo list -l 'workflows.argoproj.io/phase in (Pending, Running)' $@ | sk --header-lines=1 -m | awk '{print $1}') $@
# }

# aestop() {
#   argo stop $(argo list -l 'workflows.argoproj.io/phase in (Pending, Running)' -n argo-events | sk --header-lines=1 -m | awk '{print $1}') -n argo-events
# }


dimage() {
    docker images | sk --header-lines=1 -m | awk '{print $1":"$2}'
}

dlogs() {
    local container=$(docker ps -a | sk --header-lines=1 --preview "docker logs {1} --tail 20" | awk '{print $1}')
    if [ -n "$container" ]; then
      docker logs -f $container
    fi
}

# afailed() {
#     argo list -l 'workflows.argoproj.io/phase=Failed' | sk --header-lines=1 --preview "argo logs {1}" | awk '{print $1}'
# }


# a more readable netstat
alias ntst="sudo netstat -tulpn"

# get cwd and environment for a specific process
cwdp () { sudo ls -l "/proc/$1/cwd" ;}
envp () { sudo cat "/proc/$1/environ" ;}

F () { find . -type f -name $*;}
psg () { ps -ef | grep -v 'sk --header-lines=1' | sk --header-lines=1 $@ | awk '{print $2}' }
psk () { kill $(ps -ef | sk --header-lines=1 $@ | awk '{print $2}') }
pytop() { S py-spy top --pid $(psg -q "python") }
pydump() {S py-spy record -o dump.svg --pid $(psg -q "python")}

alias inside="docker run -it --rm --entrypoint=/bin/bash"
dselect () { docker ps -a $@ | sk --header-lines=1 -m | awk '{print $1}' }
diselect () { docker images $@ | sk --header-lines=1 -m | awk '{print $1":"$2}' }
rmdock () {
    case $1 in
      "-a")  docker rm $(docker ps -a -q)    ;;
      "-af") docker rm -f $(docker ps -a -q) ;;
      *)     docker rm $@ $(dselect)         ;;
    esac
}
rmsince (){ docker rm $2 $(docker ps -q --filter=since=$1) }
rmidangling () { docker rmi $1 $(docker images -f "dangling=true" -q)}
# docker images --format "{{.Repository}}:{{.Tag}}"
rmidock () { docker rmi $(diselect) }


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

aws_assume_env() {
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

awp_env() {
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

awp() {
    if [ "$1" = "-u" ]; then
        unset AWS_PROFILE
        return
    fi
    if [ -n "$1" ]; then
      local profile=$(sed -E 's/\[(.*)\]/\1/' < ~/.aws/config | awk '{print $2}' | grep $1)
    fi
    if [ ! -n "$profile" ]; then
      local profile=$(grep -E '^\[profile ' ~/.aws/config | sed -E 's/\[(.*)\]/\1/' | awk '{print $2}' | sk)
    fi
    export AWS_PROFILE=$profile
}

gwp() {
    gcloud config set project $(gcloud projects list | sk --header-lines 1 | awk '{print $1}')
}

g_iam_roles() {
    gcloud iam roles list --format json | jq '.[].name' -r | sk --preview 'gcloud iam roles describe {}' -m
}

bqtbl() {
    bq query --nouse_legacy_sql  --format=json '
    DECLARE datasets STRING;
    SET datasets = (
      SELECT ARRAY_TO_STRING(
        ARRAY_AGG(
            FORMAT("""SELECT table_catalog || "." || table_schema || "." || table_name as table, creation_time FROM `%s.%s.INFORMATION_SCHEMA.TABLES`""", catalog_name, schema_name)
          ), "\nUNION ALL\n"
        ) FROM INFORMATION_SCHEMA.SCHEMATA
    );

    EXECUTE IMMEDIATE datasets;' | jq -r '.[][].table' | sk -m --preview 'bqddl {}'
}

bquri() {
    local PROJECT=$(gcloud projects list | sk --header-lines 1 | awk '{print $1}')
    local DATASET=$(bq --project_id ${PROJECT} ls -n 1000 | sk --header-lines 2 | awk '{print $1}')
    bq --project_id ${PROJECT} ls -n 1000 ${DATASET} | sk --header-lines 2 -m | \
        awk -v p=${PROJECT} -v d=${DATASET} '{print "bq:/" p "/" d "/" $1 }'
}

bqhead() {
    local DATASET=$(bq ls | sk --header-lines 2 | awk '{print $1}')
    local TABLE=$(bq ls ${DATASET} | sk --header-lines 2 | awk '{print $1}')
    bq head ${DATASET}.${TABLE}
}

bqddl() {
    if [ ! -n "$1" ]; then
        local PROJECT=$(gcloud projects list | sk --header-lines 1 | awk '{print $1}')
        local DATASET=$(bq --project_id ${PROJECT} ls | sk --header-lines 2 | awk '{print $1}')
        local TABLE=$(bq --project_id ${PROJECT} ls ${DATASET} | sk --header-lines 2 | awk '{print $1}')
    else
        local PROJECT=$(echo ${1} | cut -s -d . -f1)
        if [ ! -n "$PROJECT" ]; then
            local PROJECT=${1}
            local DATASET=$(bq --project_id ${PROJECT} ls | sk --header-lines 2 | awk '{print $1}')
            local TABLE=$(bq --project_id ${PROJECT} ls ${DATASET} | sk --header-lines 2 | awk '{print $1}')
        else
            local DATASET=$(echo ${1} | cut -s -d . -f2)
            local TABLE=$(echo ${1} | cut -s -d . -f3)
            if [ ! -n "$TABLE" ]; then
              local TABLE=$(bq --project_id ${PROJECT} ls ${DATASET} | sk --header-lines 2 | awk '{print $1}')
            fi
        fi
    fi
    bq --project_id ${PROJECT} query --format=sparse --nouse_legacy_sql "select ddl from ${DATASET}.INFORMATION_SCHEMA.TABLES where table_name = '${TABLE}'"
}


bqcount() {
    local DATASET=$(bq ls | sk --header-lines 2 | awk '{print $1}')
    for TABLE in $(bq ls ${DATASET} | sk -m --header-lines 2 | awk '{print $1}')
    do
      bq query --format=sparse --nouse_legacy_sql "select count(*) from ${DATASET}.${TABLE}"
    done
}

get_topic() {
    ~/go/bin/topicctl --cluster-config ${1:-cluster.yml} get topics --no-spinner 2>&1 \
      | sk --header-lines=5 --preview "~/go/bin/topicctl get offsets {2} --cluster-config ${1:-cluster.yml} --no-spinner 2>&1" \
      | awk '{print $1}'
}

# auto completes --------------------------------------------------------------
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/vault vault
[ -f ~/.k8s_completion.zsh ] && source ~/.k8s_completion.zsh
[ -f ~/.krew/bin ] && export PATH=~/.krew/bin:${PATH}

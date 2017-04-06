for script in /etc/profile.d/*.sh ; do
    if [ -r $script ] ; then
        . $script
    fi
done

if [[ -r /etc/profile.d/bash_prompt.sh ]]; then
    . /etc/profile.d/bash_prompt.sh
elif [[ -r /etc/profile.d/color_prompt ]]; then
    . /etc/profile.d/color_prompt
else
    export PS1='\[\033[01;32m\]\h\[\033[01;36m\]\W$ \[\033[00m\]'
fi

function forwardSsh_help() {

    cat <<EOM
usage:  forwardSsh
... adds all of your .ssh keys to an ssh-agent for the current shell
EOM

}
function forwardSsh() {
    echo "... generating agent for ssh forwarding in cluster"
    pkill ssh-agent
    eval $(ssh-agent)
    for privateKey in $(ls -1 $HOME/.ssh/id_* | grep -v '\.pub')
    do
        addKey "$privateKey"
    done
    ssh-add -l # verify your key has been added to the key-ring
}

function addKey_help() {
    cat <<EOM
usage:  addKey </path/to/private_ssh_key>
... adds key to ssh-agent's keyring
e.g.
    addKey ~/.ssh/id_rsa
EOM

}

function addKey() {
    key="$1"
    ssh-add $key
}

forwardSsh

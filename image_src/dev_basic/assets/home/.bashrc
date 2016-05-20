export PS1='\[\033[01;32m\]\h\[\033[01;36m\]\W$ \[\033[00m\]'
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
    if [[ -r ${key}.pub ]]; then
        echo "... adding key $key"
        ssh-add $key
    else
        echo "... no public key found for $key. Will skip ..."
    fi
}

forwardSsh

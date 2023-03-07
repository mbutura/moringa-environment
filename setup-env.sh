#! /bin/bash

# Options - rsa, ed25519

SCRIPT_PATH=`realpath "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_PATH"`

printf "Setting up moringa environment using %s-based SSH keys\n" "$1"

docker build --build-arg ssh_prv_key="$(cat ~/.ssh/id_$1)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_$1.pub)" -t moringa-environment $SCRIPT_DIR && docker run -p 5050:5050 -p 3000:3000 -p 5173:5173 -p 4173:4173 -p 9292:9292 -it --rm moringa-environment

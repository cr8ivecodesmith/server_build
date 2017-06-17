#!/bin/bash
# Convenience script to send the build scripts to the server

SCRIPT=$(basename $0)
SCRIPTPATH=$(readlink -f $0)
SCRIPTDIR=$(dirname $SCRIPTPATH)
FILENAME="${SCRIPT%.*}"

function log {
    level=$1
    msg=$2
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${timestamp}] ${FILENAME} ${level} - ${msg}" \
        >> $SCRIPTDIR/${FILENAME}.log
}


## MAIN ##
USR=$1
SRV=$2

log INFO "Sending command scripts to $SRV"
rsync -avhP server_build.sh $USR@$SRV:/root/

log INFO "Sending config files to $SRV"
rsync -avhP conf $USR@$SRV:/root/

log INFO "Sending dotfile archive to $SRV"
rsync -avhP srv-dotfiles.tar.gz $USR@$SRV:/root/

log INFO "Done"

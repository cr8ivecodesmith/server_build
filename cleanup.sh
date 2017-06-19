#!/bin/bash
# Performs cleanup

function log {
    level=$1
    msg=$2
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${timestamp}] ${FILENAME} ${level} - ${msg}" \
        >> $SCRIPTDIR/${FILENAME}.log
}


## MAIN ##
if ! [ $(id -u) = 0 ]; then
    log ERROR "These commands have to run as root!"
    exit 1
fi


log INFO "Cleaning up"
cat /dev/null > /root/.bash_history \
    && history -c \
    && history -w

apt autoclean -y \
    && apt autoremove -y  \
    && apt purge -y \
    && rm -rfv /tmp/* \
    && rm -rfv /var/tmp/*


log INFO "Done"

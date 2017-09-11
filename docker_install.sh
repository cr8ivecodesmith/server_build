#!/bin/bash
# Server Build Script
SCRIPT=$(basename $0)
SCRIPTPATH=$(readlink -f $0)
SCRIPTDIR=$(dirname $SCRIPTPATH)
FILENAME="${SCRIPT%.*}"


# This script will always install the latest version of docker.
# docker-compose should be updated accordingly as well. To check the latest
# version of compose go to:
# https://github.com/docker/compose/releases
DOCKER_VER=17.06.2~ce-0~ubuntu
COMPOSE_VER=1.15.0


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


log INFO "Upgrading initial packages"
apt -o Acquire::ForceIPv4=true update --fix-missing


log INFO "Installing initial packages"
apt -o Acquire::ForceIPv4=true install  -y \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common


log INFO "Adding docker repo"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


log INFO "Installing docker"
apt -o Acquire::ForceIPv4=true update --fix-missing \
    && apt -o Acquire::ForceIPv4=true install -y docker-ce=$DOCKER_VER


log INFO "Installing docker-compose"
curl -L \
    https://github.com/docker/compose/releases/download/$COMPOSE_VER/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


log INFO "Starting up docker"
service docker start

log INFO "Done"

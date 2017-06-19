#!/bin/bash
# Server Build Script
SCRIPT=$(basename $0)
SCRIPTPATH=$(readlink -f $0)
SCRIPTDIR=$(dirname $SCRIPTPATH)
FILENAME="${SCRIPT%.*}"

SRVDOTFILES=srv-dotfiles.tar.gz

# Edit the ff. variables accordingly
SUPERUSER=yoursuperuser
SUPERPASS=yoursuperpass
PRIVKEY_STR="""
ssh-rsa <LONG_RSA_STR> ${SUPERUSER}@localhost
"""

# This script will always install the latest version of docker.
# docker-compose should be updated accordingly as well. To check the latest
# version of compose go to:
# https://github.com/docker/compose/releases
DOCKER_VER=17.03.1~ce-0~ubuntu-xenial
COMPOSE_VER=1.13.0


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


log INFO "Exporting envinronment variables for the other scripts"
export FILENAME SCRIPTDIR

log INFO "Upgrading initial packages"
apt update --fix-missing && apt upgrade -y


log INFO "Installing other packages"
apt install -y \
    sudo \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    unzip \
    curl \
    software-properties-common \
    vim \
    git \
    tmux \
    mosh \
    htop \
    tree \
    nethogs


log INFO "Adding docker repo"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


log INFO "Installing docker"
apt-get update --fix-missing && apt-get install -y docker-ce=$DOCKER_VER


log INFO "Installing docker-compose"
curl -L \
    https://github.com/docker/compose/releases/download/$COMPOSE_VER/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


log INFO "Starting up docker"
service docker start


log INFO "Creating superuser"
useradd $SUPERUSER \
    --home-dir /home/$SUPERUSER \
    --create-home \
    --shell /bin/bash \
    --user-group
echo $SUPERUSER:$SUPERPASS | chpasswd

usermod -aG sudo $SUPERUSER

log INFO "Configuring superuser"
tar xvf $SRVDOTFILES \
    --directory /home/$SUPERUSER \
    --overwrite
mkdir -p /home/$SUPERUSER/.ssh
chmod 700 /home/$SUPERUSER/.ssh
echo $PRIVKEY_STR > /home/$SUPERUSER/.ssh/authorized_keys
chmod 600 /home/$SUPERUSER/.ssh/authorized_keys
chown $SUPERUSER:$SUPERUSER -Rf /home/$SUPERUSER


log INFO "You may now run the other scripts as needed"
log INFO "Done"

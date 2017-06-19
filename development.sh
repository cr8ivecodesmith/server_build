#!/bin/bash
# Installs development packages
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
if ! [ $(id -u) = 0 ]; then
    log ERROR "These commands have to run as root!"
    exit 1
fi


log INFO "Installing development and build packages"
apt install -y \
    build-essential \
    gcc \
    g++ \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libsqlite3-dev \
    libjpeg-dev \
    libpng12-dev \
    python3-dev \
    python3-setuptools \
    python3-pip \
    python3-venv \
    python-dev \
    python-setuptools \
    python-pip \
    python-virtualenv


log INFO "Done"

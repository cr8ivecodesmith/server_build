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


log INFO "Upgrading initial packages"
apt update --fix-missing && apt upgrade -y


log INFO "Installing other packages"
apt install -y \
    curl \
    sudo \
    unzip \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    sendmail \
    fail2ban \
    ufw \
    vim \
    git \
    tmux \
    mosh \
    htop \
    tree


log INFO "Adding docker repo"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


log INFO "Installing docker"
apt-get update --fix-missing && apt-get install -y docker-ce


log INFO "Installing docker-compose"
curl -L \
    https://github.com/docker/compose/releases/download/$COMPOSE_VER/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


log INFO "Starting up docker"
service docker start


log INFO "Initial firewall config"
cp -vf conf/ufw.deb /etc/default/ufw
chmod 644 /etc/default/ufw


log INFO "Configuring fail2ban"
cp -vf conf/fail2ban.local.deb /etc/fail2ban/fail2ban.local
cp -vf conf/jail.local.deb /etc/fail2ban/jail.local
chmod 644 /etc/fail2ban/*.local
service fail2ban restart


log INFO "Configuring SSH"
cp -vf conf/sshd_config.deb /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
service ssh restart


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


log INFO "Disabling root password"
passwd -d root


log INFO "Initial firewall config"
ufw enable
ufw default allow outgoing
ufw default deny incoming
ufw allow http
ufw allow https
ufw allow ssh
ufw allow 2376/tcp
ufw allow 60000:60003/udp
ufw allow 8000,8080,8888,5000/tcp
ufw reload


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

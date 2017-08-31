#!/bin/bash
# Installs and configures basic server security
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


log INFO "Installing security packages"
apt -o Acquire::ForceIPv4=true install -y \
    sendmail \
    fail2ban \
    ufw


log INFO "Configuring base firewall settings"
cp -vf $SCRIPTDIR/conf/ufw.deb /etc/default/ufw
chmod 644 /etc/default/ufw


log INFO "Opening firewall ports"
ufw enable
ufw default allow outgoing
ufw default deny incoming
ufw allow http
ufw allow https
ufw allow ssh
ufw allow 2376/tcp
ufw allow 60000:60003/udp
ufw allow 8000,8080,5000/tcp
ufw reload


log INFO "Configuring fail2ban"
cp -vf $SCRIPTDIR/conf/fail2ban.local.deb /etc/fail2ban/fail2ban.local
cp -vf $SCRIPTDIR/conf/jail.local.deb /etc/fail2ban/jail.local
chmod 644 /etc/fail2ban/*.local
service fail2ban restart


log INFO "Configuring SSH"
cp -vf $SCRIPTDIR/conf/sshd_config.deb /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
service ssh restart


log INFO "Disabling root password"
passwd -d root


log INFO "Done"

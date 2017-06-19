Server Build
============

Configuration for Ubuntu 16.04 servers


NOTE:

This might still work for other Ubuntu/Debian versions. Adjust the commands
where necessary.


## Usage

1.) Copy and extract this to your server

```
$ apt update && apt install -y unzip
$ wget -N https://github.com/cr8ivecodesmith/server_build/archive/master.zip \
    -O /root/server_build.zip
$ cd /root/
$ unzip server_build.zip
$ chmod +x server_build-master/*.sh
```

2.) Edit the necessary variables in the `server_build.sh` script

3.) Run the `server_build.sh` script

4.) Run the `security.sh` script

5.) Run the `development.sh` script if you need it

6.) Run the `cleanup.sh` script


## ToDo

- Turn this into a python script with a configuration file


## Useful references

Redhat/Debian Commands

https://help.ubuntu.com/community/SwitchingToUbuntu/FromLinux/RedHatEnterpriseLinuxAndFedora

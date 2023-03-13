# Upgrading Nodes in Mass

If you have more than two nodes that need to be upgraded to the latest Sentinel dvpn-node software, this script and guid will help you achieve that.

## Prerequisites 
* local ssh key in `$HOME/.ssh/authorized_keys` on server
* `/etc/sudoers` for node runners usernames as follows

```shell
#
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
#
Defaults	env_reset
Defaults	mail_badpass
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root	ALL=(ALL:ALL) ALL
sentinel ALL=(ALL:ALL) NOPASSWD: ALL
v2ray ALL=(ALL:ALL) NOPASSWD: ALL

# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL

# Allow members of group sudo to execute any command
%sudo	ALL=(ALL:ALL) ALL

```

where `sentinel` and `v2ray` are the usernames of your sentinel wireguard dvpn-node runner and your sentinel v2ray dvpn-node runner.

## Upgrade script

Clone the Sentinel dvpn upgrade script repository:

```shell
git clone https://github.com/freQniK/upgrade_dvpn_nodes
cd upgrade_dvpn_nodes
```

There you will see a file called `upgrade_dvpn_nodes.sh` that looks like the following:

```shell
#!/bin/bash
#
# This will only work if you created a user name 'sentinel' with authorized ssh access 
# from your running machine. 
#
# Also need 'sentinel ALL=(ALL:ALL) NOPASSWD: ALL' in /etc/sudoers
# This can be edited afterwards to remove the NOPASSWD permissions
#
# ssh pubkey access needs to be added to your /etc/ssh/sshd_config file
# for this to work
#
###################EDIT THE FOLLOWING##########################
# May need to be edited to suit others needs
#
# EDIT THESE to all your IP ADDRESSES of your nodes
# IP addresses in single quotes separated by space
nodes=('185.113.143.101' '94.131.3.170')
#
# SSH PORT (EDIT)
port='22'
#
# USERNAME OF NODE RUNNER ON SERVER (EDIT)
username='sentinel'
#
# DVPN NODE VERSION TO USE
dvpn_version='v0.6.1'
###################END EDIT####################################

####################
# DON'T EDIT THESE
wireguard=0
v2ray=0

help_screen() {
	echo "$0 <option>"
	echo " "
        echo "Options:    "
        echo "           --v2ray,     install dvpn-node software tagged for v2ray, in v2ray user home directory"
        echo "           --help,      this screen"
        echo " "
        exit

}

while [ "$#" -gt 0 ]; do
        key=${1}

        case ${key} in
		--v2ray)
                        v2ray=1
                        shift
                        ;;
                help|--help)
                        help_screen
                        shift
                        ;;
                				
                *)
                        shift
                        ;;
        esac
done

if [[ ${v2ray} -eq 1 ]]; then
	username='v2ray'
fi


for node in ${nodes[@]}; do
        url_node="$node"
	echo "----------------------------------$url_node---------------------------------"

        ssh -p $port $username@$url_node << EOF
        rm -rf ~/dvpn-node
        git clone https://github.com/sentinel-official/dvpn-node 
EOF

        ssh -p $port $username@$url_node 'bash -s' < docker_ps.sh

        ssh -p $port $username@$url_node << EOF
        cd dvpn-node
        git checkout $dvpn_version
	if [[ ${v2ray} -eq 1 ]]; then
	        docker build --file Dockerfile --tag sentinel-dvpn-node-v2ray  --force-rm  --no-cache  --compress .
	else
	        docker build --file Dockerfile --tag sentinel-dvpn-node  --force-rm  --no-cache  --compress .
	fi
	
EOF
        
        
done

```

Edit the parameters at the beginning of the file to your setup. To run as a single dvpn-node (i.e., only a *wireguard* or *v2ray* instance, but not both) install just run:

```shell
./upgrade_dvpn_nodes.sh
```

This will ssh into each server and install the latest version of the software. Besure to restart the dvpn-node software on your server machine after this script completes. 

If you have a wireguard dvpn node running and you want to also run *v2ray* node on the same host, then make sure to run the `add_v2ray_user.sh` script which looks as follows:

```shell
#!/bin/bash
#
# This will only work if you created a user name 'sentinel' with authorized ssh key access 
# from your running machine. 
#
# Also need 'sentinel ALL=(ALL:ALL) NOPASSWD: ALL' in /etc/sudoers
# This can be edited afterwards to remove the NOPASSWD permissions
#
# ssh pubkey access needs to be added to your /etc/ssh/sshd_config file
# for this to work
#

# EDIT THESE to all your IP ADDRESSES of your nodes
nodes=('80.92.205.77' '194.156.98.199' '185.113.143.101' '94.131.3.170')

# SSH PORT (EDIT)
port='22'

# USERNAME OF DVPN NODE SOFTWARE
username='sentinel'

for node in ${nodes[@]}; do
        #url_node="$node.$url"
        url_node="$node"
        echo "$url_node"

        ssh -p $port $username@$url_node << EOF
	sudo sh -c "echo 'v2ray        ALL=(ALL:ALL)NOPASSWD: ALL' >> /etc/sudoers"

	sudo deluser v2ray
	sudo useradd -p "temp_password_1" -d /home/v2ray -m -s /bin/bash v2ray
	sudo mkdir ~v2ray/.ssh
	sudo cp ~/.ssh/authorized_keys ~v2ray/.ssh
	sudo chown -R v2ray:v2ray ~v2ray/.ssh
	sudo usermod -G docker v2ray
EOF
done

```

Editing the beginning of this file as before. Then run 

`./upgrade_dvpn_nodes.sh --v2ray` 

This will install a second instance of the dvpn-node docker container but tagged as `sentinel-dvpn-node-v2ray`  so be sure to use that when running the init scripts and starting the v2ray dvpn-node server. 

## Contact for help

I use Alter, so reach me there if you need assistance with these scripts:

### ALTER ID
```
uj9nrpg57r
```


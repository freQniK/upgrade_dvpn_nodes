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
nodes=('45.142.215.110' '193.36.118.36')

# SSH PORT (EDIT)
port='22000'

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



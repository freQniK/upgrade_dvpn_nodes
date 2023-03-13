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
nodes=('45.142.215.110' '193.36.118.36')
#
# SSH PORT (EDIT)
port='22000'
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



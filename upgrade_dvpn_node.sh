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
# May need to be edited to suit others needs

# EDIT THESE to all your IP ADDRESSES of your nodes
nodes=('x.x.x.x' 'y.y.y.y' 'z.z.z.z' 'w.w.w.w')
#url='mathnodes.com' 
# SSH PORT (EDIT)
port='22000'
# USERNAME OF DVPN NODE SOFTWARE
username='sentinel'
# DVPN NODE VERSION TO USE
dvpn_version='v0.4.0'

for node in ${nodes[@]}; do
        #url_node="$node.$url"
        url_node="$node"
        echo "$url_node"

        ssh -p $port $username@$url_node << EOF
        rm -rf ~/dvpn-node
        git clone https://github.com/sentinel-official/dvpn-node 
EOF

        ssh -p $port $username@$url_node 'bash -s' < docker_ps.sh

        ssh -p $port $username@$url_node << EOF
        cd dvpn-node
        git checkout $dvpn_version
        docker build --file Dockerfile --tag sentinel-dvpn-node  --force-rm  --no-cache  --compress .
EOF
        
        
done



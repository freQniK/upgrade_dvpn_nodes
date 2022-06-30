#!/bin/bash
#
# This will only work if you created a user name 'sentinel' with authorized ssh access 
# from your running machine. 
#
# Also need 'sentinel ALL=(ALL:ALL) NOPASSWD: ALL' in /etc/sudoers
# This can be edited afterwards to remove the NOPASSWD permissions
#
#
# May need to be edited to suit others needs

# EDIT nodes to be all the ip addresses of your dvpn nodes
# Edit port if other than port 22
# Edit username if other than 'sentinel'
nodes=('x.x.x.x' 'y.y.y.y' 'z.z.z.z' )
port='22'
username='sentinel'
version='v0.3.2'

for node in ${nodes[@]}; do
        echo `host $node`
	
        ssh -p $port $username@$node << EOF
        rm -rf ~/dvpn-node
        git clone https://github.com/sentinel-official/dvpn-node 
EOF

        ssh -p $port $username@$node 'bash -s' < docker_ps.sh

        ssh -p $port $username@$node << EOF
        cd dvpn-node
        git checkout $version
        docker build --file Dockerfile --tag sentinel-dvpn-node  --force-rm  --no-cache  --compress .
EOF
        
        
done



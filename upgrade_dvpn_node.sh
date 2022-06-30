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

# EDIT THESE to all your subdomains (nodes) of your primary domain (url) and ssh port (port)
nodes=('cantor' 'erdos' 'fibonacci' 'hecke' 'lobachevsky' 'molien' 'riemann' 'schrodinger' 'shafarevich' 'shimura' 'thabit' 'zwicky' 'bolzano' )
url='mathnodes.com' 
port='22000'
username='sentinel'

for node in ${nodes[@]}; do
        url_node="$node.$url"
        echo "$url_node"

        ssh -p $port $username@$url_node << EOF
        rm -rf ~/dvpn-node
        git clone https://github.com/sentinel-official/dvpn-node 
EOF

        ssh -p $port $username@$url_node 'bash -s' < docker_ps.sh

        ssh -p $port $username@$url_node << EOF
        cd dvpn-node
        git checkout v0.3.2 
        docker build --file Dockerfile --tag sentinel-dvpn-node  --force-rm  --no-cache  --compress .
EOF
        
        
done



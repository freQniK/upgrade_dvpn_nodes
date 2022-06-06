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

# EDIT THESE to all your subdomains (nodes) of your primary domain (url)

nodes=('poincare' 'bernoulli')
url='mathnodes.com' 

for node in ${nodes[@]}; do
        url_node="$node.$url"
        echo "$url_node"

        ssh -p 22000 sentinel@$url_node << EOF
        rm -rf ~/dvpn-node
        git clone https://github.com/sentinel-official/dvpn-node 
EOF

        ssh -p 22000 sentinel@$url_node 'bash -s' < docker_ps.sh

        ssh -p 22000 sentinel@$url_node << EOF
        cd dvpn-node
        git checkout v0.3.2 
        docker build --file Dockerfile --tag sentinel-dvpn-node  --force-rm  --no-cache  --compress .
EOF
        
        
done



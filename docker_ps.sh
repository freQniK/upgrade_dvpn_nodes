#!/bin/bash

sudo docker kill `sudo docker ps | grep "sentinel-dvpn-node" | cut -d " " -f 1`

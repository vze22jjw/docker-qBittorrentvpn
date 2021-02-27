#!/bin/bash

# Check vpn-tunnel "tun0" and ping google DNS if internet connection work
DATE=$(date "+%c")
IP_PREFIX="172"
PREFIX_REGEX="^$IP_PREFIX"
REMOTE_IP="$(ping -I tun0 -q -c 1 -W 1 8.8.4.4 | head -1 | awk '{ print $5 }')"
DOCKER_LOGS="/proc/1/fd/1"

if [[  $REMOTE_IP =~ $PREFIX_REGEX ]]; then
        echo "$DATE WARNING: HEALTHCHECK -- REMOTE IP IS $REMOTE_IP AND IT CONTAINS PREFIX $IP_PREFIX SO, ALL GOOD FOR NOW..." | tee -a $DOCKER_LOGS
        exit 0
else
        echo "$DATE ERROR: HEALTHCHECK -- REMOTE IP IS $REMOTE_IP AND DOES NOT CONTAIN PREFIX $IP_PREFIX SO, LET'S SATRT AGAIN..." | tee -a $DOCKER_LOGS
        exit 1
fi
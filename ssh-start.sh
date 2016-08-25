#!/bin/bash
# version: 09.07.02
echo "=============================="
echo "SSH-START SCRIPT BEGINNING"
eval `ssh-agent`
if [ -n "$1" ];then
    user="$1"
    echo "/home/${user}/.ssh/bbftp-key"
    ssh-add "/home/${user}/.ssh/bbftp-key"
    echo "loaded identity:"
    ssh-add -l
else
    echo "must specify a user name"
    echo "USAGE: ./ssh-start.sh [user]"
fi
echo "SSH-START SCRIPT DONE"
echo "=============================="

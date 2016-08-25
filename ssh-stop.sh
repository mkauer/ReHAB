#!/bin/bash
# version: 09.07.02
echo "=============================="
echo "SSH-STOP SCRIPT BEGINNING"
echo "current identities:"
ssh-add -l
echo "deleting identities:"
ssh-add -D
echo "identities left:"
ssh-add -l
echo "anything above this line?"
eval `ssh-agent -k`
killall -gq "ssh-agent" 2>/dev/null
echo "SSH-STOP SCRIPT DONE"
echo "=============================="

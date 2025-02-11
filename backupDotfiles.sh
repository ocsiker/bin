#!/bin/env bash
rsync -avh --update --exclude '.Trash-1000' --exclude '.cache' --include '/.*' --include /etc/fstab ~/bin ~/lib --exclude '/*' --delete ~/ ~/Alpha/backupDotfiles/$(date +%Y-%m-%d)/

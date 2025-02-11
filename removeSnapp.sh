#!/bin/env bash

for pkg in $(snap list | awk 'NR >1 {print $1'); do
	sudo snap remove $pkg
done

sudo systemctl stop snapd

sudo systemctl disable snapd

sudo apt purge snapd -y

sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd
sudo rm -rf /var/cache/snapd
sudo rm -rf ~/snap

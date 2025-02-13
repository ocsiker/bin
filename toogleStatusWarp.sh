#!/usr/bin/env bash

status=$(warp-cli status | awk -F": " '/Status update/ {print $2}')
echo $status

if [[ "$status" == "Disconnected" ]]; then
	warp-cli connect
	notify-send "Warp status" "Connected!" -t 1000
	# rofi -e "Warp connect!"
elif [[ "$status" == "Connected" ]]; then
	warp-cli disconnect
	rofi -e "Warp disconnect!"
fi

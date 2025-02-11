#!/bin/bash

# Lấy SINK mặc định
SINK=$(pactl list short sinks | awk '{print $2}')

# Kiểm tra tham số đầu vào
if [[ -z "$1" ]]; then
	echo "Usage: $0 {headphone|lineout}"
	exit 1
fi

# Chuyển đổi thiết bị âm thanh
case "$1" in
headphone | headphones)
	pactl set-sink-port "$SINK" "analog-output-headphones" && echo "Switched to Headphones"
	;;
lineout)
	pactl set-sink-port "$SINK" "analog-output-lineout" && echo "Switched to Line Out"
	;;
*)
	echo "Invalid option. Use 'headphone' or 'lineout'."
	;;
esac

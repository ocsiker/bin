#!/bin/bash

# Ghi đè file /etc/default/keyboard với cấu hình mong muốn
cat <<EOF | sudo tee /etc/default/keyboard
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS="caps:swapescape"

BACKSPACE="guess"
EOF

# Áp dụng thay đổi ngay lập tức
sudo dpkg-reconfigure keyboard-configuration
echo "Cấu hình bàn phím đã được cập nhật!"

#!/bin/bash

# Chụp màn hình và copy vào clipboard trước
flameshot gui -c

# Thư mục lưu ảnh
DEFAULT_SAVE_DIR=~/Pictures/Screenshots

# Chọn thư mục lưu ảnh qua hộp thoại Zenity, nếu không chọn sẽ dùng thư mục mặc định
SAVE_DIR=$(zenity --file-selection --directory --title="Chọn thư mục lưu ảnh" 2>/dev/null)
if [[ -z "$SAVE_DIR" ]]; then
	SAVE_DIR="$DEFAULT_SAVE_DIR"
fi

# Hộp thoại nhập tên file với Zenity
FILENAME=$(zenity --entry --title="Flameshot" --text="Nhập tên ảnh:" --entry-text="$(date '+%Y-%m-%d_%H-%M-%S')") || exit

# Nếu người dùng nhấn Cancel hoặc nhập rỗng, thoát script
if [[ -z "$FILENAME" ]]; then
	notify-send "❌ Đã hủy chụp ảnh." "Không có ảnh nào được lưu."
	exit 1
fi

# Kiểm tra xem clipboard có ảnh không trước khi lưu
if xclip -selection clipboard -t image/png -o >/dev/null 2>&1; then
	xclip -selection clipboard -t image/png -o >"$SAVE_DIR/$FILENAME.png"
	notify-send "📸 Chụp ảnh thành công!" "Ảnh đã lưu tại:\n$SAVE_DIR/$FILENAME.png"
	echo "✅ Ảnh đã lưu tại: $SAVE_DIR/$FILENAME.png"
else
	notify-send "⚠️ Lỗi!" "Không tìm thấy ảnh trong clipboard. Ảnh không được lưu."
	echo "❌ Không tìm thấy ảnh trong clipboard."
	exit 1
fi

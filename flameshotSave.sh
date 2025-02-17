#!/bin/bash

# Thư mục lưu ảnh
SAVE_DIR=~/Pictures/Screenshots

# Kiểm tra nếu thư mục không tồn tại thì tạo mới
if [[ ! -d "$SAVE_DIR" ]]; then
	mkdir -p "$SAVE_DIR"
	notify-send "📂 Đã tạo thư mục" "Thư mục $SAVE_DIR đã được tạo để lưu ảnh."
fi

# Chụp màn hình và copy vào clipboard trước
flameshot gui -c

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

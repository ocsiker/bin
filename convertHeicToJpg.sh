#!/bin/bash

# Thư mục chứa các file HEIC
INPUT_DIR="./"
OUTPUT_DIR="./converted"

# Tạo thư mục đích nếu chưa tồn tại
mkdir -p "$OUTPUT_DIR"

# Lặp qua tất cả các file HEIC trong thư mục đầu vào
for file in "$INPUT_DIR"/*.HEIC "$INPUT_DIR"/*.heic; do
	# Kiểm tra nếu file tồn tại (tránh lỗi khi không có file HEIC nào)
	if [ -f "$file" ]; then
		filename=$(basename -- "$file")
		filename_noext="${filename%.*}"
		output_file="$OUTPUT_DIR/$filename_noext.jpg"

		echo "Đang chuyển đổi: $file -> $output_file"
		heif-convert "$file" "$output_file"
	fi
done

echo "Hoàn thành! Tất cả các file HEIC đã được chuyển đổi sang JPG trong thư mục $OUTPUT_DIR."

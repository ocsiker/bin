#!/bin/bash

# Kiểm tra xem script có chạy trong tmux không
if [ -z "$TMUX" ]; then
	echo "Error: This script must be run inside a tmux session."
	exit 1
fi

# Kiểm tra xem fzf có được cài đặt không
if ! command -v fzf >/dev/null 2>&1; then
	echo "Error: fzf is not installed. Please install it (e.g., 'sudo apt install fzf')."
	exit 1
fi

# Lấy danh sách pane với session, window, pane, window_name, path, và title
panes=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}: #{window_name} #{pane_current_path} #{pane_title}")

# Xử lý từng pane để lấy tên thư mục cuối
formatted_panes=""
while read -r line; do
	# Tách các trường
	read -r session_pane window_name path title <<<"$line"
	# Lấy tên thư mục cuối
	dir_name=$(basename "$path")
	# Tạo định dạng mới
	formatted_panes+="$session_pane: $window_name/$dir_name/$title\n"
done <<<"$panes"

# Loại bỏ dòng cuối rỗng
formatted_panes=${formatted_panes%\\n}

# Kiểm tra nếu không có pane nào
if [ -z "$formatted_panes" ]; then
	echo "Error: No panes found in the current tmux session."
	exit 1
fi

# Hiển thị menu chọn bằng fzf
choice=$(echo -e "$formatted_panes" | fzf --prompt="Select pane: ")

# Nếu người dùng chọn một pane
if [[ -n "$choice" ]]; then
	# Lấy session_name và window_index.pane_index
	session_name=$(echo "$choice" | cut -d: -f1)
	pane_target=$(echo "$choice" | cut -d: -f2 | cut -d' ' -f1)
	window_index=$(echo "$pane_target" | cut -d. -f1)

	# Kích hoạt window trước, sau đó chọn pane
	tmux select-window -t "$session_name:$window_index"
	tmux select-pane -t "$session_name:$pane_target"
else
	echo "No pane selected."
fi

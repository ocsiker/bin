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

# Lấy danh sách tất cả pane từ tất cả window trong session
# Định dạng: "session_name:window_index.pane_index: window_name/pane_title"
panes=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}: #{window_name}/#{pane_title}")

# Kiểm tra nếu không có pane nào
if [ -z "$panes" ]; then
	echo "Error: No panes found in the current tmux session."
	exit 1
fi

# Hiển thị menu chọn bằng fzf
choice=$(echo "$panes" | fzf --prompt="Select pane: ")

# Nếu người dùng chọn một pane
if [[ -n "$choice" ]]; then
	# Lấy session_name và window_index.pane_index
	session_name=$(echo "$choice" | cut -d: -f1)
	pane_target=$(echo "$choice" | cut -d: -f2)
	window_index=$(echo "$pane_target" | cut -d. -f1)

	# Kích hoạt window trước, sau đó chọn pane
	tmux select-window -t "$session_name:$window_index"
	tmux select-pane -t "$session_name:$pane_target"
else
	echo "No pane selected."
fi

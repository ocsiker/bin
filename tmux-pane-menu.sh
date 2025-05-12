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

# Lấy session hiện tại
current_session=$(tmux display-message -p '#{session_name}')

# Lấy danh sách pane với session, window, pane, window_name, path, và command
panes=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} #{window_name} #{pane_current_path} #{pane_current_command}")

# Xử lý từng pane để tạo định dạng hiển thị
formatted_panes=""
while read -r line; do
	# Tách các trường
	read -r session_pane window_name path command <<<"$line"
	# Lấy tên thư mục cuối từ path, nếu path không hợp lệ thì để "unknown"
	if [[ -n "$path" && -d "$path" ]]; then
		dir_name=$(basename "$path")
	else
		dir_name="unknown"
	fi
	# Tạo định dạng mới: session_name:window_index.pane_index: window_name (command) [dir_name]
	formatted_panes+="$session_pane: $window_name ($command) [$dir_name]\n"
done <<<"$panes"

# Loại bỏ dòng cuối rỗng
formatted_panes=${formatted_panes%\\n}

# Kiểm tra nếu không có pane nào
if [ -z "$formatted_panes" ]; then
	echo "Error: No panes found in any tmux session."
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

	# Kiểm tra xem session có tồn tại không
	if ! tmux has-session -t "$session_name" 2>/dev/null; then
		echo "Error: Session $session_name does not exist."
		exit 1
	fi

	# Nếu session đích khác với session hiện tại, chuyển session trước
	if [ "$session_name" != "$current_session" ]; then
		tmux switch-client -t "$session_name"
	fi

	# Chọn window và pane
	tmux select-window -t "$session_name:$window_index"
	tmux select-pane -t "$session_name:$pane_target"
else
	echo "No pane selected."
fi

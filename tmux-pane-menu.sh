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

# Hàm kiểm tra cấu hình title trong Neovim/LazyVim
check_neovim_title() {
	local nvim_path=$(command -v nvim)
	if [ -z "$nvim_path" ]; then
		echo "Warning: Neovim not found. Please install Neovim."
		return 1
	fi

	# Tạo một session tạm để kiểm tra
	local temp_session="tmux_title_check_$$"
	tmux new-session -d -s "$temp_session" "nvim --cmd 'echo &title'"

	sleep 0.2 # Đợi Neovim khởi động
	title_status=$(tmux capture-pane -t "$temp_session:0.0" -p -S -1 | grep -o "0\\|1")
	tmux kill-session -t "$temp_session"

	if [ "$title_status" != "1" ]; then
		echo "Warning: 'title' is not enabled in Neovim/LazyVim. Please add the following to your ~/.config/nvim/init.lua or ~/.config/nvim/lua/config/options.lua:"
		echo "  vim.opt.title = true"
		echo "  vim.opt.titlestring = \"%t %m\""
		return 1
	fi
	return 0
}

# Hàm kiểm tra cấu hình set-titles trong tmux
check_tmux_titles() {
	if ! tmux show-options -g | grep -q "set-titles on"; then
		echo "Warning: 'set-titles' is not enabled in tmux. Please add the following to your ~/.tmux.conf:"
		echo "  set -g set-titles on"
		echo "Then run 'tmux source-file ~/.tmux.conf' to apply changes."
		return 1
	fi
	return 0
}

# Thực hiện kiểm tra
check_neovim_title
check_tmux_titles

# Lấy danh sách pane với thư mục và tên file
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

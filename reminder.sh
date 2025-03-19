#!/bin/bash

SCHEDULE_FILE="$HOME/lib/schedule.lst"
NOTIFIED_FILE="$HOME/lib/.notified"

# Hàm hiển thị thông báo
notify() {
	notify-send "Nhắc nhở" "$1" -t 100000
}

# Hàm thêm sự kiện với zenity
add_event() {
	datetime_input=$(GTK_THEME=Arc-Dark zenity --entry --title="Thêm sự kiện" --text="Ngày giờ (YYYY-MM-DD HH:MM hoặc HH:MM):")
	if [[ -z "$datetime_input" ]]; then exit 0; fi

	if [[ "$datetime_input" =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
		today=$(date +%Y-%m-%d)
		datetime="$today $datetime_input"
	else
		datetime="$datetime_input"
	fi

	if ! date -d "$datetime" >/dev/null 2>&1; then
		notify-send "Lỗi" "Định dạng ngày giờ không hợp lệ!" -t 5000
		exit 1
	fi

	message=$(GTK_THEME=Arc-Dark zenity --entry --title="Thêm sự kiện" --text="Nội dung:")
	if [[ -z "$message" ]]; then exit 0; fi

	repeat="no"

	echo "$datetime|$repeat|$message" >>"$SCHEDULE_FILE"
	sort -o "$SCHEDULE_FILE" "$SCHEDULE_FILE"
	notify-send "Thành công" "Đã thêm sự kiện: $datetime|$repeat|$message" -t 5000
}

# Vòng lặp kiểm tra lịch
check_schedule() {
	[[ ! -f "$NOTIFIED_FILE" ]] && touch "$NOTIFIED_FILE"

	while true; do
		now=$(date +%s)
		if [[ ! -f "$SCHEDULE_FILE" ]]; then
			sleep 5
			continue
		fi

		while IFS='|' read -r datetime repeat message; do
			event_time=$(date -d "$datetime" +%s 2>/dev/null)
			if [[ -z "$event_time" ]]; then continue; fi

			if [[ "$now" -ge "$event_time" ]]; then
				if [[ "$repeat" == "yes" ]]; then
					seconds_diff=$((now - event_time))
					if [[ $((seconds_diff % 60)) -lt 5 ]]; then
						notify "$message"
					fi
				else
					event_line="$datetime|$repeat|$message"
					if ! grep -Fx "$event_line" "$NOTIFIED_FILE" >/dev/null; then
						notify "$message"
						echo "$event_line" >>"$NOTIFIED_FILE"
					fi
				fi
			fi
		done <"$SCHEDULE_FILE"
		sleep 5
	done
}

if [[ "$1" == "add" ]]; then
	add_event
else
	check_schedule &
	pid=$!
	echo "Chương trình đang chạy ngầm (PID: $pid). Dùng 'reminder.sh add' để thêm sự kiện."
fi

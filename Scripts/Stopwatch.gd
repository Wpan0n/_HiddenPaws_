extends Label

var time_elapsed = 0.0
var max_score = 100
var current_score = 0

func update_timer_display() -> void:
	var total_seconds = int(time_elapsed)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	var time_string = "%02d:%02d" % [minutes, seconds]
	text = time_string

func stop_timer() -> void:
	set_process(false)  # Stop updating time

func set_time_elapsed(time: float) -> void:
	time_elapsed = time

func get_time_elapsed() -> float:
	return time_elapsed

extends Label

var time_elapsed = 0.0

func _ready():
	update_timer_display()

func set_time_elapsed(time: float):
	time_elapsed = time
	update_timer_display()

func update_timer_display():
	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	var milliseconds = int((time_elapsed - int(time_elapsed)) * 1000)
	text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

extends Label

var time_elapsed := 0.0

func _process(delta: float) -> void:
	time_elapsed += delta
	update_timer_display()

func update_timer_display() -> void:
	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	var milliseconds = int((time_elapsed - int(time_elapsed)) * 100)
	
	# Format the time to 00.00.00 (minutes.seconds.milliseconds)
	var time_string = String("%02d.%02d.%02d" % [minutes, seconds, milliseconds])
	text = time_string

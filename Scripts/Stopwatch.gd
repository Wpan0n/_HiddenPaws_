extends Label

var current_score = 0
var time_elapsed = 0.0
var is_running = true

func _ready():
	update_timer_display()  # Initialize display
	if not is_running:
		update_timer_display()
		print("Stopwatch: Initialized stopped, text=", text)

func set_time_elapsed(time: float):
	time_elapsed = time
	update_timer_display()

func update_timer_display():
	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	var milliseconds = int((time_elapsed - int(time_elapsed)) * 1000)
	text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

func start_timer():
	is_running = true
	update_timer_display()
	print("Stopwatch: Started, text=", text)

func stop_timer():
	is_running = false
	update_timer_display()
	print("Stopwatch: Stopped, text=", text)

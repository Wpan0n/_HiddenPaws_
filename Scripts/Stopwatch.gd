extends Label

var time_elapsed := 0.0  # Initialize a variable to keep track of the total elapsed time in seconds

# This function is called every frame and receives the delta time (time elapsed since the last frame)
func _process(delta: float) -> void:
	time_elapsed += delta  # Add the delta time to the total elapsed time
	update_timer_display()  # Call the function to update the timer display

# Function to update the displayed time on the label
func update_timer_display() -> void:
	var hours = int(time_elapsed / 3600)  # Calculate the number of hours by dividing the total seconds by 3600 (number of seconds in an hour)
	var minutes = int(time_elapsed) % 3600 / 60  # Calculate the number of minutes by first taking the integer part of time_elapsed, then using modulo 3600 to get the remaining seconds after hours, and dividing by 60
	var seconds = int(time_elapsed) % 60  # Calculate the number of seconds by taking the remainder of total seconds divided by 60
	var milliseconds = int((time_elapsed - int(time_elapsed)) * 100)  # Calculate the number of milliseconds by taking the fractional part of time_elapsed and multiplying by 100

	# Format the time string as "hh:mm:ss:ms" (hours:minutes:seconds:milliseconds)
	var time_string = String("%02d:%02d:%02d:%02d" % [hours, minutes, seconds, milliseconds])
	text = time_string  # Set the text of the label to the formatted time string

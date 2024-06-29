extends Label

var time_elapsed := 0.0  # Initialize a variable to keep track of the total elapsed time in seconds

# This function is called every frame and receives the delta time (time elapsed since the last frame)
func _process(delta: float) -> void:
	time_elapsed += delta  # Add the delta time to the total elapsed time
	update_timer_display()  # Call the function to update the timer display

# Function to update the displayed time on the label
func update_timer_display() -> void:
	var hours = int(time_elapsed / 3600.0)  # Calculate the number of hours by dividing the total seconds by 3600.0 (number of seconds in an hour)
	var minutes = int(time_elapsed / 60.0) % 60  # Calculate the number of minutes by dividing the total seconds by 60.0, then taking modulo 60
	var seconds = int(time_elapsed) % 60  # Calculate the number of seconds by taking the remainder of total seconds divided by 60
	var milliseconds = int((time_elapsed - int(time_elapsed)) * 100.0)  # Calculate the number of milliseconds by taking the fractional part of time_elapsed and multiplying by 100.0

	# Format the time string as "hh:mm:ss:ms" (hours:minutes:seconds:milliseconds)
	var time_string = "%02d:%02d:%02d:%02d" % [hours, minutes, seconds, milliseconds]
	text = time_string  # Set the text of the label to the formatted time string

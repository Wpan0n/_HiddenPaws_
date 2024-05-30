extends Sprite2D

signal sprite_clicked

# Reference to the AudioStreamPlayer node, ensuring the correct path is used
@onready var audio_player = $"../AudioStreamPlayer"

# This function is called whenever there is an input event
func _input(event):
	# Check if the event is a mouse button event
	if event is InputEventMouseButton:
		# Check if the left mouse button was pressed
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if the click was on an opaque pixel of the sprite
			if is_pixel_opaque(get_local_mouse_position()):
				print("sprite clicked")  # Print message to the console
				modulate = Color(1, 0, 0)  # Change the sprite color to red
				# Check if the audio_player node is valid
				if audio_player:
					audio_player.play()  # Play the sound effect
				else:
					print("AudioStreamPlayer node not found")  # Print error message
				
				# Emit a signal to notify that the sprite was clicked
				emit_signal("sprite_clicked")
				print("Signal emitted")  # Print a message when the signal is emitted

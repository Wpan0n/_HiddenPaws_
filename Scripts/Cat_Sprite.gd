extends Sprite2D

signal sprite_color_changed

@onready var audio_player = $"../AudioStreamPlayer"
var clicked = false  # Variable to track if the sprite has been clicked

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_pixel_opaque(get_local_mouse_position()):
				print("sprite clicked")  # Print message to the console
				modulate = Color(0.5, 0.5, 0.5)  # Changed to grey (RGB 0.5, 0.5, 0.5)
				if audio_player:
					audio_player.play()  # Play the sound effect
				else:
					print("AudioStreamPlayer node not found")  # Print error message
				
				# Emit a signal to notify that the sprite's color has changed only if not clicked before
				if not clicked:
					emit_signal("sprite_color_changed")
					print("Signal emitted")  # Print a message when the signal is emitted
					clicked = true  # Set the clicked state to true to prevent further score increments

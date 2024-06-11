extends Sprite2D

signal sprite_color_changed

@onready var audio_player = $"../AudioStreamPlayer"

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_pixel_opaque(get_local_mouse_position()):
				print("sprite clicked")  # Print message to the console
				modulate = Color(1, 0, 0)  # Change the sprite color to red
				if audio_player:
					audio_player.play()  # Play the sound effect
				else:
					print("AudioStreamPlayer node not found")  # Print error message
				
				# Emit a signal to notify that the sprite's color has changed
				emit_signal("sprite_color_changed")
				print("Signal emitted")  # Print a message when the signal is emitted

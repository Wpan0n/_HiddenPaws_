extends Sprite2D

@onready var audio_player = $"../AudioStreamPlayer"  # Use the correct node path

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_pixel_opaque(get_local_mouse_position()):
				print("sprite clicked")
				modulate = Color(1, 0, 0)  # Change the sprite color to red
				if audio_player:  # Check if the audio_player node is valid
					audio_player.play()  # Play the sound effect
				else:
					print("AudioStreamPlayer node not found")

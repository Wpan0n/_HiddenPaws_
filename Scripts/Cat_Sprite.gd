extends Sprite2D

signal sprite_color_changed

@onready var audio_player = $"../AudioStreamPlayer"
var clicked = false  # Track click state

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_pixel_opaque(get_local_mouse_position()):
				print("sprite clicked")
				modulate = Color("#bebebe")  # Changed to hex color code
				
				if audio_player:
					audio_player.play()
				else:
					print("AudioStreamPlayer node not found")
				
				if not clicked:
					emit_signal("sprite_color_changed")
					print("Signal emitted")
					clicked = true

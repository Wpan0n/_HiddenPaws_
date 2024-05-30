extends Sprite2D

signal sprite_color_changed

@onready var audio_player = $"../AudioStreamPlayer"
var score = 0

# Dictionary to track clicked state for each sprite
var spriteClickedStates = {}

func _ready():
	# Initialize clicked state for this sprite
	spriteClickedStates[self] = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_pixel_opaque(get_local_mouse_position()) and !spriteClickedStates[self]:
				print("Sprite clicked")
				modulate = Color(1, 0, 0)
				if audio_player:
					audio_player.play()
				else:
					print("AudioStreamPlayer node not found")
				emit_signal("sprite_color_changed")
				print("Signal emitted")
				score += 1
				print("Score:", score)
				spriteClickedStates[self] = true  # Mark this sprite as clicked

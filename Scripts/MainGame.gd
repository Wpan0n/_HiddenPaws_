extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body if needed.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Check if the "Escape" key is just pressed
	if Input.is_action_just_pressed("Escape"):
		# Change the scene to the main menu
		get_tree().change_scene_to_file("res://Scences/main_menu.tscn")

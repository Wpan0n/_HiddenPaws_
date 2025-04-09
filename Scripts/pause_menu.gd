extends Control

@onready var optionsMenu = preload("res://Scenes/options_menu.tscn")

func _ready():
	$AnimationPlayer.play("RESET")
	hide()  # Start hidden
	set_process_input(true)  # Ensure input is being processed

func _input(event):
	if event.is_action_pressed("Escape"):
		if get_tree().paused:
			resume()
		else:
			pause()

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()

func pause():
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func _on_resume_pressed():
	resume()

func _on_quit_pressed():
	get_tree().quit()

func _on_options_pressed():
	resume()
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")

func _on_settings_pressed():
	resume()
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")

func _on_reset_pressed():
	print("Reset button pressed!")
	# Example: get_tree().reload_current_scene()
	# Replace with your actual reset logic if needed

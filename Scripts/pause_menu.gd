extends Control

@onready var optionsMenu = preload("res://Scenes/options_menu.tscn")

func _ready():
	$AnimationPlayer.play("RESET")
	hide()
	set_process_input(true)
	var reset_button = find_child("Reset", true, false)
	if reset_button and reset_button is Button:
		if not reset_button.pressed.is_connected(_on_reset_pressed):
			reset_button.pressed.connect(_on_reset_pressed)
	else:
		printerr("Error: Reset button not found in PauseMenu")

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
	save_game_state()
	resume()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_options_pressed():
	save_game_state()
	resume()
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")

func _on_settings_pressed():
	save_game_state()
	resume()
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")

func _on_reset_pressed():
	if SaveGame:
		SaveGame.reset_game()
		var game_ui = get_tree().get_first_node_in_group("game_ui")
		if game_ui and game_ui.has_method("reset_game_state"):
			game_ui.reset_game_state()
		else:
			printerr("Error: GameUI node not found or missing reset_game_state method")
		resume()
	else:
		printerr("Error: SaveGame singleton not found!")

func save_game_state():
	var game_ui = get_tree().get_first_node_in_group("game_ui")
	if game_ui and game_ui.has_method("save_game_state"):
		game_ui.save_game_state()
	else:
		printerr("Error: GameUI node not found or missing save_game_state method")

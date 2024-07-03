extends Control

# @onready ensures that these variables are assigned only after the node and its children are ready.
@onready var start_button = $MarginContainer/VBoxContainer/Start_Button
@onready var settings_button = $MarginContainer/VBoxContainer/Settings_Button
@onready var quit_button = $MarginContainer/VBoxContainer/Quit_Button

# Preload the scene for the main game level. This loads the scene when the script is parsed, 
# allowing for quick switching to this scene later.
@onready var start_level = preload("res://Scences/MainGame.tscn") as PackedScene

# Preload the scene for the settings menu.
@onready var settings_scene = preload("res://Scences/options_menu.tscn") as PackedScene


# This function will be called when the settings button is pressed.
func _on_settings_button_pressed():
	# Change the current scene to the preloaded settings scene.
	get_tree().change_scene_to_packed(settings_scene)

# This function will be called when the quit button is pressed.
func _on_quit_button_pressed():
	# Quit the application.
	get_tree().quit()


func _on_start_button_pressed():
	# Change the current scene to the preloaded start level scene.
	get_tree().change_scene_to_packed(start_level)

func _on_Button_pressed():
	

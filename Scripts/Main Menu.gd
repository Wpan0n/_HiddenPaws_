extends Control

@onready var start_button = $MarginContainer/VBoxContainer/Start_Button
@onready var settings_button = $MarginContainer/VBoxContainer/Settings_Button
@onready var quit_button = $MarginContainer/VBoxContainer/Quit_Button

@onready var start_level = preload("res://Scenes/MainGame.tscn") as PackedScene
@onready var settings_scene = preload("res://Scenes/options_menu.tscn") as PackedScene

func _ready():
	print("Main menu ready")

func _on_settings_button_pressed():
	get_tree().change_scene_to_packed(settings_scene)

func _on_quit_button_pressed():
	get_tree().quit()

func _on_start_button_pressed():
	get_tree().change_scene_to_packed(start_level)

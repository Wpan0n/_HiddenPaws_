extends Control

# --- What This Script Does ---
# This script controls the main menu of the game, which is the first screen the player sees.
# It has buttons to start the game, go to the settings menu, or quit the game.

# --- Node References ---
# These connect to the buttons in the main menu.
@onready var start_button = $MarginContainer/VBoxContainer/Start_Button  # The button to start the game.
@onready var settings_button = $MarginContainer/VBoxContainer/Settings_Button  # The button to open settings.
@onready var quit_button = $MarginContainer/VBoxContainer/Quit_Button  # The button to quit the game.

# --- Preloaded Scenes ---
# These load the scenes for the game and settings menu so we can switch to them.
@onready var start_level = preload("res://Scenes/MainGame.tscn") as PackedScene  # The main game scene.
@onready var settings_scene = preload("res://Scenes/options_menu.tscn") as PackedScene  # The settings menu scene.

# --- How This Works When the Game Starts ---
func _ready():
	# This runs when the game starts.
	# Print a message to the console to confirm the main menu is ready.
	print("Main menu ready")

# --- When the Settings Button Is Pressed ---
func _on_settings_button_pressed():
	# This runs when the player clicks the Settings button.
	# Switch to the settings menu scene.
	get_tree().change_scene_to_packed(settings_scene)

# --- When the Quit Button Is Pressed ---
func _on_quit_button_pressed():
	# This runs when the player clicks the Quit button.
	# Close the game completely.
	get_tree().quit()

# --- When the Start Button Is Pressed ---
func _on_start_button_pressed():
	# This runs when the player clicks the Start button.
	# Switch to the main game scene to start playing.
	get_tree().change_scene_to_packed(start_level)

# --- How to Fix Common Issues ---
# 1. If the buttons don’t work:
#    - Make sure the buttons are named correctly in the scene (Start_Button, Settings_Button, Quit_Button).
#      Open the scene (likely res://Scenes/main_menu.tscn), find the buttons under MarginContainer/VBoxContainer, and check their names.
#    - Make sure each button’s "pressed" signal is connected to the right function.
#      In the editor, select each button, go to the Node dock > Signals tab, and check that "pressed" is connected (e.g., Start_Button’s "pressed" should connect to "_on_start_button_pressed").
# 2. If the game doesn’t start or settings menu doesn’t open:
#    - Make sure the scene files exist at the correct paths ("res://Scenes/MainGame.tscn" and "res://Scenes/options_menu.tscn").
#      In the Godot editor, go to the FileSystem tab (bottom left), and check that these files are in the right folders.
#    - Make sure the scenes are set up correctly (e.g., MainGame.tscn should have all the game elements like sprites and the camera).
# 3. If the game doesn’t quit:
#    - The "get_tree().quit()" function should work on most platforms.
#    - If it doesn’t, let me know what platform you’re using (Windows, Mac, etc.), and we can find another way to quit.

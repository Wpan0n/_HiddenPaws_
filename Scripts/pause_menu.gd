extends Control

# --- What This Script Does ---
# This script controls the pause menu in the game. When the player presses the Escape key,
# it shows a menu with buttons like Resume, Quit, Options, Settings, and Reset.
# The menu pauses the game, plays a blur animation, and lets the player choose what to do next.
# It also saves the game progress when needed (like when quitting or resetting).

# --- Preloaded Scenes ---
# This loads the options menu scene so we can switch to it later.
@onready var optionsMenu = preload("res://Scenes/options_menu.tscn")

# --- How This Works When the Game Starts ---
func _ready():
	# This runs when the game starts.
	
	# Play an animation called "RESET" to set up the pause menu.
	# This might hide the menu or reset its appearance.
	$AnimationPlayer.play("RESET")
	
	# Hide the pause menu when the game starts (we don’t want it visible right away).
	hide()
	
	# Tell Godot we want to handle player input (like pressing the Escape key).
	set_process_input(true)
	
	# Find the Reset button in the pause menu.
	# "find_child" looks for a node named "Reset" in the scene.
	var reset_button = find_child("Reset", true, false)
	# Check if we found the Reset button and if it’s actually a button.
	if reset_button and reset_button is Button:
		# Connect the button’s "pressed" signal to our _on_reset_pressed function.
		# This means when the button is clicked, it will run _on_reset_pressed.
		if not reset_button.pressed.is_connected(_on_reset_pressed):
			reset_button.pressed.connect(_on_reset_pressed)
	else:
		# If we can’t find the Reset button, show an error in the Godot console.
		printerr("Error: Reset button not found in pause_menu")

# --- Handle Player Input (Like Pressing Escape) ---
func _input(event):
	# This runs whenever the player presses a key or moves the mouse.
	
	# Check if the player pressed the Escape key.
	if event.is_action_pressed("Escape"):
		# If the game is already paused...
		if get_tree().paused:
			# Unpause the game (resume playing).
			resume()
		else:
			# Pause the game and show the pause menu.
			pause()

# --- Resume the Game ---
func resume():
	# This unpauses the game and hides the pause menu.
	
	# Unpause the game (everything starts moving again).
	get_tree().paused = false
	# Play the "blur" animation backwards to unblur the screen.
	$AnimationPlayer.play_backwards("blur")
	# Hide the pause menu.
	hide()

# --- Pause the Game ---
func pause():
	# This pauses the game and shows the pause menu.
	
	# Show the pause menu.
	show()
	# Pause the game (everything stops moving).
	get_tree().paused = true
	# Play the "blur" animation to blur the screen.
	$AnimationPlayer.play("blur")

# --- When the Resume Button Is Pressed ---
func _on_resume_pressed():
	# This runs when the player clicks the Resume button.
	# It just calls the resume function to unpause the game.
	resume()

# --- When the Quit Button Is Pressed ---
func _on_quit_pressed():
	# This runs when the player clicks the Quit button.
	
	# Save the game progress before quitting.
	save_game_state()
	# Unpause the game (needed before changing scenes).
	resume()
	# Switch to the main menu scene.
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# --- When the Options or Settings Button Is Pressed ---
# Note: Both buttons do the same thing right now (go to the options menu).
func _on_options_pressed():
	# This runs when the player clicks the Options button.
	
	# Save the game progress before switching scenes.
	save_game_state()
	# Unpause the game (needed before changing scenes).
	resume()
	# Switch to the options menu scene.
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")

func _on_settings_pressed():
	# This runs when the player clicks the Settings button.
	# It does the same thing as the Options button.
	
	# Save the game progress before switching scenes.
	save_game_state()
	# Unpause the game (needed before changing scenes).
	resume()
	# Switch to the options menu scene.
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")

# --- When the Reset Button Is Pressed ---
func _on_reset_pressed():
	# This runs when the player clicks the Reset button.
	
	# Check if the SaveGame script exists.
	if SaveGame:
		# Reset the saved game progress (like score and time).
		SaveGame.reset_game()
		# Find the GameUI script (it controls the game’s UI, like the score).
		var game_ui = get_tree().get_first_node_in_group("game_ui")
		# Check if we found GameUI and if it has a reset_game_state function.
		if game_ui and game_ui.has_method("reset_game_state"):
			# Reset the game’s UI (like setting the score back to 0).
			game_ui.reset_game_state()
			# Unpause the game and hide the pause menu.
			resume()
		else:
			# If GameUI isn’t found, show an error in the Godot console.
			printerr("Error: GameUI node not found or missing reset_game_state method")
	else:
		# If SaveGame isn’t found, show an error in the Godot console.
		printerr("Error: SaveGame singleton not found!")

# --- Save the Game Progress ---
func save_game_state():
	# This saves the game progress by telling GameUI to save.
	
	# Find the GameUI script.
	var game_ui = get_tree().get_first_node_in_group("game_ui")
	# Check if we found GameUI and if it has a save_game_state function.
	if game_ui and game_ui.has_method("save_game_state"):
		# Save the game progress (score, time, etc.).
		game_ui.save_game_state()
	else:
		# If GameUI isn’t found, show an error in the Godot console.
		printerr("Error: GameUI node not found or missing save_game_state method")

# --- How to Fix Common Issues ---
# 1. If the pause menu doesn’t appear when you press Escape:
#    - Make sure this script is attached to the pause menu node in your scene.
#      Open the scene (likely res://Scenes/MainGame.tscn), right-click the pause menu node, and check its script in the Inspector.
#    - Check that the "Escape" key is set up in Godot:
#      Go to Project > Project Settings > Input Map, look for "Escape", and make sure it’s mapped to the Escape key.
#    - Make sure the pause menu node is in the scene (e.g., in res://Scenes/MainGame.tscn).
# 2. If the buttons (Resume, Quit, etc.) don’t work:
#    - Make sure the buttons are named correctly in the scene (Resume, Quit, Options, Settings, Reset).
#      Open the scene, find the buttons, and check their names in the Scene tree.
#    - Make sure each button’s "pressed" signal is connected to the right function.
#      In the editor, select each button, go to the Node dock > Signals tab, and check that "pressed" is connected (e.g., Resume’s "pressed" should connect to "_on_resume_pressed").
# 3. If the game doesn’t unpause or switch scenes:
#    - Make sure the scene files exist at the correct paths ("res://Scenes/main_menu.tscn" and "res://Scenes/options_menu.tscn").
#      In the Godot editor, go to the FileSystem tab (bottom left), and check that these files are in the right folders.
#    - Make sure the AnimationPlayer has a "blur" animation.
#      Select the AnimationPlayer node in the scene, open the Animation tab (bottom), and check that there’s a "blur" animation.

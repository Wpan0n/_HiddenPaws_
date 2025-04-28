extends Control

# --- What This Script Does ---
# This script controls the options menu where the player can change game settings.
# It lets the player adjust the master volume, screen settings (like fullscreen or windowed),
# vertical sync (vsync), and brightness. It saves these settings to a file so they’re remembered.

# --- Save File Path ---
# This is where the settings are saved on the player’s computer.
const SAVE_PATH = "user://settings.cfg"

# --- Settings Storage ---
# This creates a file to save the settings.
var config = ConfigFile.new()

# --- Default Settings ---
# These are the starting settings for the game if there’s no saved file.
var settings = {
	"audio_master_volume": 1.0,  # Volume for all sounds (1.0 is full volume).
	"fullscreen": false,  # True if the game is fullscreen, False if not.
	"borderless": false,  # True if the game is borderless fullscreen, False if not.
	"vsync": false,  # True if vertical sync is on (reduces screen tearing), False if off.
	"brightness": 1.0,  # Brightness of the game (1.0 is normal).
	"windowed": false  # True if the game is in windowed mode, False if not.
}

# --- UI State Tracking ---
# This keeps track of the slider positions so they can be saved and loaded.
var ui_state = {
	"slider_positions": {
		"master": 1.0,  # Position of the master volume slider.
		"brightness": 1.0  # Position of the brightness slider.
	}
}

# --- Node References ---
# These connect to the sliders, buttons, and other elements in the options menu.
@onready var master_slider = $AudioOptions/VBoxContainer/MasterSlider  # Slider for master volume.
@onready var brightness_slider = $AudioOptions/VBoxContainer/BrightnessSlider  # Slider for brightness.
@onready var fullscreen = $VBoxContainer/FullScreenLabel/Fullscreen  # Checkbox for fullscreen mode.
@onready var borderless = $VBoxContainer/BorderlessLabel/Borderless  # Checkbox for borderless mode.
@onready var windowed = $VBoxContainer/WindowedLabel/Windowed  # Checkbox for windowed mode.
@onready var v_sync = $VBoxContainer/VSyncLabel2/VSync  # Checkbox for vertical sync.
@onready var back_button = $Back_Button  # Button to go back to the main menu.

# --- How This Works When the Game Starts ---
func _ready():
	# This runs when the game starts.
	
	# Print a message to the console to confirm the options menu is ready.
	print("Options menu ready, loading settings...")
	# Load the saved settings from the file.
	load_settings()
	# Apply the settings to the game (like setting the volume and screen mode).
	apply_settings()
	# Set the sliders to the saved positions.
	restore_ui_state()
	# Print the loaded settings to the console for debugging.
	print("Initial settings applied: ", settings)
	
	# Update the checkboxes to match the loaded settings.
	update_button_states()

# --- Set Sliders to Saved Positions ---
func restore_ui_state():
	# This sets the sliders to the saved positions so they look correct.
	if master_slider:
		# Set the master volume slider to the saved position.
		master_slider.value = ui_state["slider_positions"]["master"]
	if brightness_slider:
		# Set the brightness slider to the saved position.
		brightness_slider.value = ui_state["slider_positions"]["brightness"]

# --- Save the Settings to a File ---
func save_settings():
	# This saves the settings to a file so they’re remembered next time the game starts.
	
	# Print the settings we’re saving for debugging.
	print("Saving settings: ", settings)
	# Save each setting to the file.
	config.set_value("audio", "master_volume", settings["audio_master_volume"])
	config.set_value("display", "fullscreen", settings["fullscreen"])
	config.set_value("display", "borderless", settings["borderless"])
	config.set_value("display", "vsync", settings["vsync"])
	config.set_value("display", "brightness", settings["brightness"])
	config.set_value("windowed", "windowed", settings["windowed"])
	config.set_value("ui_state", "slider_positions", ui_state["slider_positions"])  # Save UI state
	# Write the settings to the file.
	var err = config.save(SAVE_PATH)
	if err != OK:
		# If there’s an error saving, show it in the console.
		print("Error saving settings: ", err)
	else:
		# If saving worked, confirm it.
		print("Settings saved successfully to ", SAVE_PATH)

# --- Load the Settings from a File ---
func load_settings():
	# This loads the saved settings from a file.
	
	# Print a message to confirm we’re loading settings.
	print("Loading settings from ", SAVE_PATH)
	# Try to load the file.
	var err = config.load(SAVE_PATH)
	if err == OK:
		# If the file loaded successfully, get the saved values.
		# If a value isn’t found, use the default (like 1.0 for volume).
		settings["audio_master_volume"] = config.get_value("audio", "master_volume", 1.0)
		settings["fullscreen"] = config.get_value("display", "fullscreen", false)
		settings["borderless"] = config.get_value("display", "borderless", false)
		settings["vsync"] = config.get_value("display", "vsync", false)
		settings["brightness"] = config.get_value("display", "brightness", 1.0)
		settings["windowed"] = config.get_value("windowed", "windowed", false)
		# Load the slider positions.
		ui_state["slider_positions"] = config.get_value("ui_state", "slider_positions", {
			"master": settings["audio_master_volume"],
			"brightness": settings["brightness"]
		})
		# Print the loaded settings for debugging.
		print("Loaded settings: ", settings)
	else:
		# If there’s no saved file, use the default settings.
		print("No settings file found, using defaults: ", settings)

# --- Apply the Settings to the Game ---
func apply_settings():
	# This applies the settings to the game (like changing the volume or screen mode).
	
	# Print the settings we’re applying for debugging.
	print("Applying settings: ", settings)
	# Set the sliders to the saved values.
	if master_slider:
		master_slider.value = settings["audio_master_volume"]
	if brightness_slider:
		brightness_slider.value = settings["brightness"]
	
	# Convert the master volume to a decibel value (how Godot handles sound).
	var master_db = linear_to_db(settings["audio_master_volume"])
	# Apply the volume to the master audio bus (index 0).
	AudioServer.set_bus_volume_db(0, master_db)
	
	# Set the screen mode based on the settings.
	if settings["fullscreen"]:
		# Make the game fullscreen.
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif settings["borderless"]:
		# Make the game borderless fullscreen.
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif settings["windowed"]:
		# Make the game windowed.
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Turn vertical sync on or off.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings["vsync"] else DisplayServer.VSYNC_DISABLED)
	# Set the game’s brightness.
	GlobalWorldEnvironment.environment.adjustment_brightness = settings["brightness"]

# --- Update Checkbox States ---
func update_button_states():
	# This updates the checkboxes to match the current settings.
	if is_instance_valid(fullscreen):
		# Set the fullscreen checkbox.
		fullscreen.button_pressed = settings["fullscreen"]
	if is_instance_valid(borderless):
		# Set the borderless checkbox.
		borderless.button_pressed = settings["borderless"]
	if is_instance_valid(windowed):
		# Set the windowed checkbox.
		windowed.button_pressed = settings["windowed"]
	if is_instance_valid(v_sync):
		# Set the vsync checkbox.
		v_sync.button_pressed = settings["vsync"]

# --- When the Master Volume Slider Changes ---
func _on_master_slider_value_changed(value):
	# This runs when the player moves the master volume slider.
	
	# Save the slider position.
	ui_state["slider_positions"]["master"] = value
	# Update the setting.
	settings["audio_master_volume"] = value
	# Convert the slider value to a decibel value.
	var master_db = linear_to_db(value)
	# Apply the volume to the master audio bus.
	AudioServer.set_bus_volume_db(0, master_db)
	# Save the settings right away.
	save_settings()

# --- When the Brightness Slider Changes ---
func _on_brightness_slider_value_changed(value):
	# This runs when the player moves the brightness slider.
	
	# Save the slider position.
	ui_state["slider_positions"]["brightness"] = value
	# Update the setting.
	settings["brightness"] = value
	# Apply the brightness to the game.
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	# Save the settings right away.
	save_settings()

# --- When the Fullscreen Checkbox Is Toggled ---
func _on_fullscreen_toggled(button_pressed):
	# This runs when the player toggles the fullscreen checkbox.
	
	# Update the setting.
	settings["fullscreen"] = button_pressed
	# Make sure only one screen mode is active.
	settings["borderless"] = false
	settings["windowed"] = false
	# Apply the new settings.
	apply_settings()
	# Save the settings.
	save_settings()
	# Update the checkboxes.
	update_button_states()

# --- When the Borderless Checkbox Is Toggled ---
func _on_borderless_toggled(button_pressed):
	# This runs when the player toggles the borderless checkbox.
	
	# Update the setting.
	settings["borderless"] = button_pressed
	# Make sure only one screen mode is active.
	settings["fullscreen"] = false
	settings["windowed"] = false
	# Apply the new settings.
	apply_settings()
	# Save the settings.
	save_settings()
	# Update the checkboxes.
	update_button_states()

# --- When the Windowed Checkbox Is Toggled ---
func _on_windowed_toggled(button_pressed):
	# This runs when the player toggles the windowed checkbox.
	
	# Update the setting.
	settings["windowed"] = button_pressed
	# Make sure only one screen mode is active.
	settings["fullscreen"] = false
	settings["borderless"] = false
	# Apply the new settings.
	apply_settings()
	# Save the settings.
	save_settings()
	# Update the checkboxes.
	update_button_states()

# --- When the VSync Checkbox Is Toggled ---
func _on_v_sync_toggled(button_pressed):
	# This runs when the player toggles the vsync checkbox.
	
	# Update the setting.
	settings["vsync"] = button_pressed
	# Apply the vsync setting.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings["vsync"] else DisplayServer.VSYNC_DISABLED)
	# Apply the new settings.
	apply_settings()
	# Save the settings.
	save_settings()
	# Update the checkboxes.
	update_button_states()

# --- When the Back Button Is Pressed ---
func _on_back_button_pressed():
	# This runs when the player clicks the Back button.
	
	# Print a message for debugging.
	print("Back button pressed, changing scene to main menu")
	# Switch to the main menu scene.
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# --- How to Fix Common Issues ---
# 1. If the settings don’t save or load:
#    - Make sure the game has permission to save files on your computer.
#    - Check that the path "user://settings.cfg" is correct (it saves in a special folder Godot uses).
#    - If you see "Error saving settings", try deleting the file (search for "settings.cfg" on your computer) and let the game create a new one.
# 2. If the sliders or checkboxes don’t work:
#    - Make sure they’re named correctly in the scene (MasterSlider, BrightnessSlider, Fullscreen, etc.).
#      Open the scene (res://Scenes/options_menu.tscn), and check the names of the nodes.
#    - Make sure their signals are connected.
#      In the editor, select each node, go to the Node dock > Signals tab, and check that the signals (like "value_changed" for sliders or "toggled" for checkboxes) are connected to the right functions.
# 3. If the screen mode doesn’t change:
#    - Make sure the settings are being applied correctly in the "apply_settings()" function.
#    - Test on your specific platform (Windows, Mac, etc.), as some platforms handle screen modes differently.
# 4. If the game is slow when changing settings:
#    - The "save_settings()" function might be slowing things down if called too often.
#    - You can reduce how often it saves by only calling it when the player presses a "Save" button (instead of after every change).

extends Control

# --- What This Script Does ---
# This script controls the options menu where the player can adjust the game’s sound settings.
# It has sliders to change the volume for the master audio (all sounds) and sound effects (SFX).
# When the player moves a slider, it changes the volume right away.

# --- How This Works When the Game Starts ---
func _ready():
	# This runs when the game starts.
	
	# Set the MasterSlider to the current volume of the master audio (all sounds in the game).
	# "AudioServer" is a part of Godot that controls sound.
	# "get_bus_volume_db(0)" gets the volume of the master audio (0 is the master audio’s ID).
	# "db_to_linear" changes the volume from a decibel value (how Godot stores it) to a number the slider can use (0 to 1).
	$VBoxContainer/MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	
	# Set the SfxSlider to the current volume of the sound effects (SFX).
	# "get_bus_volume_db(1)" gets the volume of the SFX audio (1 is the SFX audio’s ID).
	$VBoxContainer/SfxSlider.value = db_to_linear(AudioServer.get_bus_volume_db(1))

# --- When the Mouse Leaves the MasterSlider ---
func _on_master_slider_mouse_exited():
	# This runs when the player’s mouse moves off the MasterSlider.
	# "release_focus()" makes sure the slider isn’t highlighted anymore, which helps with navigating the menu.
	release_focus()

# --- When the Mouse Leaves the MusicSlider ---
func _on_music_slider_2_mouse_exited():
	# This runs when the player’s mouse moves off the MusicSlider.
	# Note: There’s no MusicSlider in this script, so this might be a leftover from an older version.
	# "release_focus()" makes sure the slider isn’t highlighted anymore.
	release_focus()

# --- When the Mouse Leaves the SfxSlider ---
func _on_sfx_slider_mouse_exited():
	# This runs when the player’s mouse moves off the SfxSlider.
	# "release_focus()" makes sure the slider isn’t highlighted anymore.
	release_focus()

# --- When the Apply Button Is Pressed ---
func _on_apply_pressed():
	# This runs when the player clicks the Apply button in the options menu.
	# Right now, it doesn’t do anything (it says "pass").
	# If you want the Apply button to save the settings or do something else, you can add that here.
	# For example, you could save the volume settings to a file or apply other changes.
	pass # Replace with function body.

# --- How to Fix Common Issues ---
# 1. If the sliders don’t show the correct volume when the game starts:
#    - Make sure the sliders are named "MasterSlider" and "SfxSlider" in the Godot editor.
#      Open the scene (likely res://Scenes/options_menu.tscn), find the sliders under VBoxContainer, and check their names.
#    - Make sure the audio buses are set up in Godot:
#      Go to Project > Project Settings > Audio > Buses, and check that there are at least two buses: one for Master (index 0) and one for SFX (index 1).
# 2. If the MusicSlider error appears in the console:
#    - The function "_on_music_slider_2_mouse_exited()" is trying to work with a MusicSlider, but there isn’t one.
#    - If you don’t need a MusicSlider, you can delete this function.
#    - If you want a MusicSlider, add a new HSlider node in the scene under VBoxContainer, name it "MusicSlider2", and connect its "mouse_exited" signal to this function.
# 3. If the Apply button doesn’t do anything:
#    - Right now, the "_on_apply_pressed()" function is empty.
#    - To make it save settings, you can copy the save logic from another script (like options_menu.gd) and add it here.
#    - For example, you could save the slider values to a file or apply them to the game.

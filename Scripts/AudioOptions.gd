extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the MasterSlider value to match the current volume of the master audio bus.
	# The bus index for master audio is assumed to be 10.
	# db_to_linear converts the decibel value to a linear value for the slider.
	$VBoxContainer/MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	
	# Set the SfxSlider value to match the current volume of the SFX audio bus.
	# The bus index for SFX audio is assumed to be 1.
	# db_to_linear converts the decibel value to a linear value for the slider.
	$VBoxContainer/SfxSlider.value = db_to_linear(AudioServer.get_bus_volume_db(1))

# Called when the mouse exits the area of the MasterSlider.
# This function releases the focus from the slider, which is useful for UI interaction.
func _on_master_slider_mouse_exited():
	release_focus()

# Called when the mouse exits the area of the MusicSlider.
# This function releases the focus from the slider, which is useful for UI interaction.
func _on_music_slider_2_mouse_exited():
	release_focus()

# Called when the mouse exits the area of the SfxSlider.
# This function releases the focus from the slider, which is useful for UI interaction.
func _on_sfx_slider_mouse_exited():
	release_focus()

# Method called when the apply button is pressed.
# This function is currently empty and needs to be implemented with desired functionality.
func _on_apply_pressed():
	pass # Replace with function body.

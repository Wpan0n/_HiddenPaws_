extends Control


# Import the necessary audio-related classes.
var audio_server = Engine.get_singleton("AudioServer")
var level_music: AudioStream
var level_music_player: AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	# Load the music stream for preview.	
	level_music = preload("res://assets/Sfx_Music/inspiring-technology-143299.mp3")
	# Create an AudioStreamPlayer for previewing the music.
	level_music_player = AudioStreamPlayer.new()
	# Add the AudioStreamPlayer as a child of this node.
	add_child(level_music_player)


# Method called when the apply button is pressed.
func _on_apply_pressed():
	# Check if the AudioOptions node exists before accessing its child nodes.
	if $AudioOptions:
		print("AudioOptions node found.")
		var master_value = $AudioOptions/VBoxContainer/MasterSlider.value
		var sfx_value = $AudioOptions/VBoxContainer/SfxSlider.value
		print("MasterSlider value: ", master_value)
		print("SfxSlider value: ", sfx_value)
		# Adjust the volume of the audio buses based on the slider values.
		audio_server.set_bus_volume_db(0, linear_to_db(master_value))
		audio_server.set_bus_volume_db(1, linear_to_db(sfx_value))
	else:
		print("AudioOptions node not found.")


# Method called when the back button is pressed.
func _on_back_button_pressed():
	# Change the scene to the main menu scene.
	get_tree().change_scene_to_file("res://scences/main_menu.tscn")

# Method called when the volume sliders' values change.
func _on_volume_slider_value_changed(slider: Slider, value: float) -> void:
	# Check which slider was changed and update the volume accordingly.
	match slider.name:
		"MasterSlider":
			audio_server.set_bus_volume_db(0, linear_to_db(value))
		"MusicSlider":
			audio_server.set_bus_volume_db(1, linear_to_db(value))
			# Update music preview volume.
			level_music_player.volume_db = linear_to_db(value)
		"SfxSlider":
			audio_server.set_bus_volume_db(2, linear_to_db(value))

# Method called when the preview button is pressed.
func _on_preview_button_pressed() -> void:
	# Play the music preview.
	level_music_player.stream = level_music
	level_music_player.play()


func _on_fullscreen_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_borderless_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_v_sync_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_windowed_toggled(toggled_on):
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_brightness_slider_value_changed(value):
	GlobalWorldEnvironment.environment.adjustment_brightness = value

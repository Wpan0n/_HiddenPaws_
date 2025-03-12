extends Control

# Autoload this script as "Settings"
const SAVE_PATH = "user://settings.cfg"
var config = ConfigFile.new()

# Default settings
var settings = {
	"audio_master_volume": 1.0,
	"fullscreen": false,
	"borderless": false,
	"vsync": false,
	"brightness": 1.0
}

# Preload the music file (optional, if you want to play it manually later)
const level_music = preload("res://assets/Sfx_Music/inspiring-technology-143299.mp3")

@onready var master_slider = $AudioOptions/VBoxContainer/MasterSlider
@onready var fullscreen_button = $VBoxContainer/Fullscreen
@onready var borderless_button = $VBoxContainer/Borderless
@onready var vsync_button = $VBoxContainer/VSync
@onready var brightness_slider = $VBoxContainer/BrightnessSlider
@onready var apply_button = $VBoxContainer/Apply
@onready var back_button = $VBoxContainer/Back
@onready var level_music_player = $AudioStreamPlayer  # Assuming this exists for music

func _ready():
	print("Options menu ready, loading settings...")
	load_settings()
	apply_settings()
	print("Initial settings applied: ", settings)

func save_settings():
	print("Saving settings: ", settings)
	config.set_value("audio", "master_volume", settings["audio_master_volume"])
	config.set_value("display", "fullscreen", settings["fullscreen"])
	config.set_value("display", "borderless", settings["borderless"])
	config.set_value("display", "vsync", settings["vsync"])
	config.set_value("display", "brightness", settings["brightness"])
	var err = config.save(SAVE_PATH)
	if err != OK:
		print("Error saving settings: ", err)
	else:
		print("Settings saved successfully to ", SAVE_PATH)

func load_settings():
	print("Loading settings from ", SAVE_PATH)
	var err = config.load(SAVE_PATH)
	if err == OK:
		settings["audio_master_volume"] = config.get_value("audio", "master_volume", 1.0)
		settings["fullscreen"] = config.get_value("display", "fullscreen", false)
		settings["borderless"] = config.get_value("display", "borderless", false)
		settings["vsync"] = config.get_value("display", "vsync", false)
		settings["brightness"] = config.get_value("display", "brightness", 1.0)
		print("Loaded settings: ", settings)
	else:
		print("No settings file found, using defaults: ", settings)

func apply_settings():
	print("Applying settings: ", settings)
	# Sync UI with settings (no immediate volume apply needed since slider handles it)
	if master_slider:
		master_slider.value = settings["audio_master_volume"]
		print("Set MasterSlider value to ", master_slider.value)
	if fullscreen_button:
		fullscreen_button.button_pressed = settings["fullscreen"]
	if borderless_button:
		borderless_button.button_pressed = settings["borderless"]
	if vsync_button:
		vsync_button.button_pressed = settings["vsync"]
	if brightness_slider:
		brightness_slider.value = settings["brightness"]
		print("Set BrightnessSlider value to ", brightness_slider.value)

	# Apply display settings
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED)
	if settings["borderless"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings["vsync"] else DisplayServer.VSYNC_DISABLED)
	
	# Apply brightness
	GlobalWorldEnvironment.environment.adjustment_brightness = settings["brightness"]
	print("Set brightness to ", settings["brightness"])

func _on_apply_pressed():
	print("Apply button pressed")
	settings["audio_master_volume"] = master_slider.value if master_slider else 1.0
	settings["fullscreen"] = fullscreen_button.button_pressed if fullscreen_button else false
	settings["borderless"] = borderless_button.button_pressed if borderless_button else false
	settings["vsync"] = vsync_button.button_pressed if vsync_button else false
	settings["brightness"] = brightness_slider.value if brightness_slider else 1.0
	print("Updated settings before applying: ", settings)
	
	apply_settings()
	save_settings()

func _on_master_slider_value_changed(value):
	# Apply volume change immediately to preview
	settings["audio_master_volume"] = value
	var master_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(0, master_db)
	if level_music_player and level_music_player.is_playing():
		level_music_player.volume_db = master_db
	print("Master slider moved, applied value: ", value, " (", master_db, " dB)")

func _on_fullscreen_toggled(button_pressed):
	settings["fullscreen"] = button_pressed
	apply_settings()

func _on_borderless_toggled(button_pressed):
	settings["borderless"] = button_pressed
	apply_settings()

func _on_v_sync_toggled(button_pressed):
	settings["vsync"] = button_pressed
	apply_settings()

func _on_brightness_slider_value_changed(value):
	settings["brightness"] = value
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	print("Brightness slider moved, new value: ", value)

func _on_back_button_pressed():
	apply_settings()
	save_settings()
	print("Back button pressed, changing scene to main menu")
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

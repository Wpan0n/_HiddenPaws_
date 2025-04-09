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
	"brightness": 1.0,
	"windowed": false
}

# UI State Tracking
var ui_state = {
	"slider_positions": {
		"master": 1.0,
		"brightness": 1.0
	}
}

#const level_music = preload("res://assets/Sfx_Music/inspiring-technology-143299.mp3") # REMOVED

@onready var master_slider = $AudioOptions/VBoxContainer/MasterSlider
@onready var brightness_slider = $AudioOptions/VBoxContainer/BrightnessSlider
@onready var fullscreen = $VBoxContainer/FullScreenLabel/Fullscreen
@onready var borderless = $VBoxContainer/BorderlessLabel/Borderless
@onready var windowed = $VBoxContainer/WindowedLabel/Windowed
@onready var v_sync = $VBoxContainer/VSyncLabel2/VSync
@onready var back_button = $Back_Button
#@onready var level_music_player = $Sprite2D # REMOVED

func _ready():
	print("Options menu ready, loading settings...")
	load_settings()
	apply_settings()
	restore_ui_state()  # Restore slider positions visually
	print("Initial settings applied: ", settings)

# Restore slider visuals from saved UI state
func restore_ui_state():
	if master_slider:
		master_slider.value = ui_state["slider_positions"]["master"]
	if brightness_slider:
		brightness_slider.value = ui_state["slider_positions"]["brightness"]

func save_settings():
	print("Saving settings: ", settings)
	config.set_value("audio", "master_volume", settings["audio_master_volume"])
	config.set_value("display", "fullscreen", settings["fullscreen"])
	config.set_value("display", "borderless", settings["borderless"])
	config.set_value("display", "vsync", settings["vsync"])
	config.set_value("display", "brightness", settings["brightness"])
	config.set_value("display", "ui_state", ui_state["slider_positions"])  # Save UI state
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
		settings["windowed"] = config.get_value("display", "windowed", false)
		ui_state["slider_positions"] = config.get_value("display", "ui_state", {  # Load UI state
			"master": settings["audio_master_volume"],
			"brightness": settings["brightness"]
		})
		print("Loaded settings: ", settings)
	else:
		print("No settings file found, using defaults: ", settings)

func apply_settings():
	print("Applying settings: ", settings)
	if master_slider:
		master_slider.value = settings["audio_master_volume"]
	if brightness_slider:
		brightness_slider.value = settings["brightness"]
	
	var master_db = linear_to_db(settings["audio_master_volume"])
	AudioServer.set_bus_volume_db(0, master_db)
	#if level_music_player: # REMOVED
	#	level_music_player.volume_db = master_db # REMOVED
	
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif settings["borderless"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif settings["windowed"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings["vsync"] else DisplayServer.VSYNC_DISABLED)
	GlobalWorldEnvironment.environment.adjustment_brightness = settings["brightness"]

# Signal handlers now autosave immediately after changes
func _on_master_slider_value_changed(value):
	ui_state["slider_positions"]["master"] = value  # Track slider position visually
	settings["audio_master_volume"] = value         # Update functional value
	var master_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(0, master_db)
	#if level_music_player: # REMOVED
	#	level_music_player.volume_db = master_db # REMOVED
	save_settings()  # Autosave

func _on_brightness_slider_value_changed(value):
	ui_state["slider_positions"]["brightness"] = value  # Track slider position visually
	settings["brightness"] = value                      # Update functional value
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	save_settings()  # Autosave

func _on_fullscreen_toggled(button_pressed):
	settings["fullscreen"] = button_pressed
	settings["borderless"] = false  # Ensure mutual exclusivity
	settings["windowed"] = false
	apply_settings()
	save_settings()

func _on_borderless_toggled(button_pressed):
	settings["borderless"] = button_pressed
	settings["fullscreen"] = false
	settings["windowed"] = false
	apply_settings()
	save_settings()

func _on_windowed_toggled(button_pressed):
	settings["windowed"] = button_pressed
	settings["fullscreen"] = false
	settings["borderless"] = false
	apply_settings()
	save_settings()

func _on_v_sync_toggled(button_pressed):
	settings["vsync"] = button_pressed
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings["vsync"] else DisplayServer.VSYNC_DISABLED)
	apply_settings()
	save_settings()

func _on_back_button_pressed():
	print("Back button pressed, changing scene to main menu")
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

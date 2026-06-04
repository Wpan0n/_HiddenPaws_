extends Control

const SAVE_PATH = "user://settings.cfg"

var config = ConfigFile.new()

var settings = {
	"audio_master_volume": 1.0,
	"fullscreen": false,
	"borderless": false,
	"vsync": false,
	"brightness": 1.0,
	"windowed": false
}

var ui_state = {
	"slider_positions": {
		"master": 1.0,
		"brightness": 1.0
	}
}

@onready var master_slider = $AudioOptions/VBoxContainer/MasterSlider
@onready var brightness_slider = $AudioOptions/VBoxContainer/BrightnessSlider
@onready var fullscreen = $VBoxContainer/FullScreenLabel/Fullscreen
@onready var borderless = $VBoxContainer/BorderlessLabel/Borderless
@onready var windowed = $VBoxContainer/WindowedLabel/Windowed
@onready var v_sync = $VBoxContainer/VSyncLabel2/VSync
@onready var back_button = $Back_Button

func _ready():
	print("Options menu ready, loading settings...")
	load_settings()
	if master_slider:
		var current_master_linear = db_to_linear(AudioServer.get_bus_volume_db(0))
		master_slider.value = current_master_linear
		settings["audio_master_volume"] = current_master_linear
		ui_state["slider_positions"]["master"] = current_master_linear
	if brightness_slider:
		brightness_slider.value = GlobalWorldEnvironment.environment.adjustment_brightness
		settings["brightness"] = brightness_slider.value
		ui_state["slider_positions"]["brightness"] = brightness_slider.value
	apply_settings()
	print("Initial settings applied: ", settings)
	update_button_states()

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
	config.set_value("windowed", "windowed", settings["windowed"])
	config.set_value("ui_state", "slider_positions", ui_state["slider_positions"])
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
		settings["windowed"] = config.get_value("windowed", "windowed", false)
		ui_state["slider_positions"] = config.get_value("ui_state", "slider_positions", {
			"master": settings["audio_master_volume"],
			"brightness": settings["brightness"]
		})
		print("Loaded settings: ", settings)
	else:
		print("No settings file found, using defaults: ", settings)

func apply_settings():
	print("Applying settings: ", settings)
	var master_db = linear_to_db(settings["audio_master_volume"])
	AudioServer.set_bus_volume_db(0, master_db)

	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		print("Applied: Fullscreen mode")
	elif settings["borderless"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var screen_size = DisplayServer.screen_get_size()
		DisplayServer.window_set_size(screen_size)
		DisplayServer.window_set_position(Vector2.ZERO)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
		print("Applied: Borderless fullscreen")
	elif settings["windowed"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2(1024, 600))
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
		print("Applied: Windowed mode")

	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings["vsync"] else DisplayServer.VSYNC_DISABLED)
	GlobalWorldEnvironment.environment.adjustment_brightness = settings["brightness"]

func update_button_states():
	if is_instance_valid(fullscreen):
		fullscreen.button_pressed = settings["fullscreen"]
	if is_instance_valid(borderless):
		borderless.button_pressed = settings["borderless"]
	if is_instance_valid(windowed):
		windowed.button_pressed = settings["windowed"]
	if is_instance_valid(v_sync):
		v_sync.button_pressed = settings["vsync"]

func _on_master_slider_value_changed(value):
	ui_state["slider_positions"]["master"] = value
	settings["audio_master_volume"] = value
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	save_settings()

func _on_brightness_slider_value_changed(value):
	ui_state["slider_positions"]["brightness"] = value
	settings["brightness"] = value
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	save_settings()

func _on_fullscreen_toggled(button_pressed):
	print("Fullscreen toggled to: ", button_pressed)
	settings["fullscreen"] = button_pressed
	settings["borderless"] = false
	settings["windowed"] = false
	apply_settings()
	save_settings()
	update_button_states()

func _on_borderless_toggled(button_pressed):
	print("Borderless toggled to: ", button_pressed)
	settings["borderless"] = button_pressed
	settings["fullscreen"] = false
	settings["windowed"] = false
	apply_settings()
	save_settings()
	update_button_states()

func _on_windowed_toggled(button_pressed):
	print("Windowed toggled to: ", button_pressed)
	settings["windowed"] = button_pressed
	settings["fullscreen"] = false
	settings["borderless"] = false
	apply_settings()
	save_settings()
	update_button_states()

func _on_v_sync_toggled(button_pressed):
	settings["vsync"] = button_pressed
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings["vsync"] else DisplayServer.VSYNC_DISABLED)
	apply_settings()
	save_settings()
	update_button_states()

func _on_back_button_pressed():
	# FIXED: Instead of always going to main_menu, we check SaveGame.previous_scene
	# which was set by whoever opened this options screen.
	# "game" means the player came from the pause menu mid-game — return to the game.
	# Anything else means they came from the main menu — return there.
	# Note: returning to MainGame.tscn will reload the scene, but SaveGame preserves
	# their progress so they won't lose their cats.
	print("Back button pressed, previous_scene=", SaveGame.previous_scene)
	if SaveGame.previous_scene == "game":
		SaveGame.previous_scene = "menu"  # Reset for next time
		get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

extends Node

# --- What This Script Does ---
# This script is a singleton that manages saving and loading the game's progress.
# It saves the player's score, elapsed time, clicked cats, and game state.

# --- Save File Path ---
const SAVE_PATH = "user://savegame.json"

# --- Game State Variables ---
var high_score: int = 0
var best_time: float = 0.0
var clicked_cats: Array = []
var game_completed: bool = false
var stopwatch_running: bool = true

# ADDED: Tracks which scene opened the options menu so Back knows where to return.
# "game" = came from pause menu mid-game. "menu" = came from main menu.
# This lives in memory only (not saved to disk) since it only matters within one session.
var previous_scene: String = "menu"

func _ready():
	load_game()
	print("SaveGame loaded: high_score=", high_score, ", best_time=", best_time, ", clicked_cats=", clicked_cats, ", game_completed=", game_completed, ", stopwatch_running=", stopwatch_running)

func save_game(time: float, score: int, cats: Array):
	high_score = score
	best_time = time
	clicked_cats = cats

	var save_data = {
		"high_score": high_score,
		"best_time": best_time,
		"clicked_cats": clicked_cats,
		"game_completed": game_completed,
		"stopwatch_running": stopwatch_running
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(save_data))
		file.close()
		print("Game saved successfully to ", SAVE_PATH)
	else:
		printerr("Error: Could not save game to ", SAVE_PATH)

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			var json = JSON.new()
			var error = json.parse(json_text)
			if error == OK:
				var data = json.get_data()
				high_score = data.get("high_score", 0)
				best_time = data.get("best_time", 0.0)
				clicked_cats = data.get("clicked_cats", [])
				game_completed = data.get("game_completed", false)
				stopwatch_running = data.get("stopwatch_running", true)
				print("Game loaded successfully from ", SAVE_PATH)
			else:
				printerr("Error: Could not parse save file: ", json.get_error_message())
		else:
			printerr("Error: Could not load game from ", SAVE_PATH)
	else:
		print("No save file found, using default values.")

func get_high_score() -> int:
	return high_score

func get_best_time() -> float:
	return best_time

func get_clicked_cats() -> Array:
	return clicked_cats

func get_game_completed() -> bool:
	return game_completed

func set_game_completed(completed: bool):
	game_completed = completed

func get_stopwatch_running() -> bool:
	return stopwatch_running

func set_stopwatch_running(running: bool):
	stopwatch_running = running

func reset_game():
	high_score = 0
	best_time = 0.0
	clicked_cats = []
	game_completed = false
	stopwatch_running = true
	save_game(0.0, 0, [])

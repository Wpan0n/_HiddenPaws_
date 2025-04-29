extends Node

# --- What This Script Does ---
# This script is a singleton that manages saving and loading the game’s progress.
# It saves the player’s score, elapsed time, clicked cats, and game state (like whether the game is completed).

# --- Save File Path ---
# This is where the game progress is saved on the player’s computer.
const SAVE_PATH = "user://savegame.json"

# --- Game State Variables ---
# These store the game’s progress.
var high_score: int = 0  # The player’s highest score (number of cats clicked).
var best_time: float = 0.0  # The shortest time it took to finish the game.
var clicked_cats: Array = []  # List of names of clicked cats (e.g., ["Sprite1", "Sprite2"]).
var game_completed: bool = false  # True if the player has finished the game.
var stopwatch_running: bool = true  # True if the stopwatch should be running.

# --- How This Works When the Game Starts ---
func _ready():
	# This runs when the game starts.
	
	# Load the saved game progress.
	load_game()
	# Print the loaded state for debugging.
	print("SaveGame loaded: high_score=", high_score, ", best_time=", best_time, ", clicked_cats=", clicked_cats, ", game_completed=", game_completed, ", stopwatch_running=", stopwatch_running)

# --- Save the Game Progress ---
func save_game(time: float, score: int, cats: Array):
	# This saves the game progress to a file.
	
	# Update the game state.
	high_score = score
	best_time = time
	clicked_cats = cats
	
	# Create a dictionary to store the data.
	var save_data = {
		"high_score": high_score,
		"best_time": best_time,
		"clicked_cats": clicked_cats,
		"game_completed": game_completed,
		"stopwatch_running": stopwatch_running
	}
	
	# Open the save file for writing.
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		# Convert the data to JSON and save it.
		file.store_line(JSON.stringify(save_data))
		file.close()
		print("Game saved successfully to ", SAVE_PATH)
	else:
		# If there’s an error saving, show it in the console.
		printerr("Error: Could not save game to ", SAVE_PATH)

# --- Load the Game Progress ---
func load_game():
	# This loads the saved game progress from a file.
	
	# Check if the save file exists.
	if FileAccess.file_exists(SAVE_PATH):
		# Open the save file for reading.
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			# Read the JSON data and parse it.
			var json_text = file.get_as_text()
			file.close()
			var json = JSON.new()
			var error = json.parse(json_text)
			if error == OK:
				var data = json.get_data()
				# Load the data into the game state.
				high_score = data.get("high_score", 0)
				best_time = data.get("best_time", 0.0)
				clicked_cats = data.get("clicked_cats", [])
				game_completed = data.get("game_completed", false)
				stopwatch_running = data.get("stopwatch_running", true)
				print("Game loaded successfully from ", SAVE_PATH)
			else:
				# If there’s an error parsing the JSON, show it in the console.
				printerr("Error: Could not parse save file: ", json.get_error_message())
		else:
			# If there’s an error opening the file, show it in the console.
			printerr("Error: Could not load game from ", SAVE_PATH)
	else:
		# If there’s no save file, use the default values.
		print("No save file found, using default values.")

# --- Get the High Score ---
func get_high_score() -> int:
	return high_score

# --- Get the Best Time ---
func get_best_time() -> float:
	return best_time

# --- Get the Clicked Cats ---
func get_clicked_cats() -> Array:
	return clicked_cats

# --- Get Whether the Game Is Completed ---
func get_game_completed() -> bool:
	return game_completed

# --- Set Whether the Game Is Completed ---
func set_game_completed(completed: bool):
	game_completed = completed

# --- Get Whether the Stopwatch Is Running ---
func get_stopwatch_running() -> bool:
	return stopwatch_running

# --- Set Whether the Stopwatch Is Running ---
func set_stopwatch_running(running: bool):
	stopwatch_running = running

# --- Reset the Game Progress ---
func reset_game():
	# This resets the game progress to start a new game.
	high_score = 0
	best_time = 0.0
	clicked_cats = []
	game_completed = false
	stopwatch_running = true
	# Save the reset state.
	save_game(0.0, 0, [])

# --- How to Fix Common Issues ---
# 1. If the game doesn’t save or load:
#    - Make sure the game has permission to save files on your computer.
#    - Check that the path "user://savegame.json" is correct (it saves in a special folder Godot uses).
#    - If you see "Error: Could not save game", try deleting the file (search for "savegame.json" on your computer) and let the game create a new one.
# 2. If the SaveGame singleton isn’t found:
#    - Make sure this script is set as a singleton in Godot.
#      Go to Project > Project Settings > AutoLoad, add "SaveGame.gd" (path: res://Scripts/SaveGame.gd), and enable it.
#    - Make sure the script is at the correct path (res://Scripts/SaveGame.gd).
#      In the Godot editor, go to the FileSystem tab (bottom left), and check that the file is in the right folder.

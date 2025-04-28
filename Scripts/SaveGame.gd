extends Node

const SAVE_PATH = "user://savegame.json"

func _ready():
	var dir = DirAccess.open("user://")
	if not dir:
		var err = DirAccess.make_dir_absolute("user://")
		if err != OK:
			printerr("Error: Could not create user:// directory at %s. Error code: %s" % [OS.get_user_data_dir(), err])
	if not FileAccess.file_exists(SAVE_PATH):
		reset_game()
	else:
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			if content.strip_edges() != "":
				var json = JSON.new()
				var error = json.parse(content)
				if error != OK:
					printerr("Error: Invalid JSON in save file during _ready, recreating: ", json.get_error_message())
					reset_game()
			else:
				printerr("Error: Save file is empty, recreating")
				reset_game()
		else:
			printerr("Error: Could not read save file, recreating")
			reset_game()

func save_game(time: float, score: int, clicked_cats: Array):
	var data = {}
	var write_file

	if FileAccess.file_exists(SAVE_PATH):
		var read_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if read_file:
			var content = read_file.get_as_text()
			read_file.close()
			if content.strip_edges() != "":
				var json = JSON.new()
				var error = json.parse(content)
				if error == OK:
					data = json.data
				else:
					printerr("Error: Invalid JSON in save file, resetting data: ", json.get_error_message())
					data = {
						"best_time": 0.0,
						"high_score": 0,
						"clicked_cats": [],
						"game_completed": false,
						"stopwatch_running": true
					}
		else:
			printerr("Error: Could not open save file for reading")
			data = {
				"best_time": 0.0,
				"high_score": 0,
				"clicked_cats": [],
				"game_completed": false,
				"stopwatch_running": true
			}
	else:
		data = {
			"best_time": time,
			"high_score": score,
			"clicked_cats": clicked_cats,
			"game_completed": false,
			"stopwatch_running": true
		}

	# Update data
	data["best_time"] = time
	data["high_score"] = max(data.get("high_score", score), score)
	data["clicked_cats"] = clicked_cats
	data["game_completed"] = data.get("game_completed", false)
	data["stopwatch_running"] = data.get("stopwatch_running", not data.get("game_completed", false))

	# Write to file
	write_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file:
		write_file.store_string(JSON.stringify(data, "\t"))
		write_file.close()
	else:
		printerr("Error: Could not open save file for writing at %s" % SAVE_PATH)

func get_high_score() -> int:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			if content.strip_edges() != "":
				var json = JSON.new()
				var error = json.parse(content)
				if error == OK:
					return json.data.get("high_score", 0)
				else:
					printerr("Error: Invalid JSON in save file: ", json.get_error_message())
					reset_game()
		else:
			printerr("Error: Could not open save file for reading")
			reset_game()
	return 0

func get_best_time() -> float:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			if content.strip_edges() != "":
				var json = JSON.new()
				var error = json.parse(content)
				if error == OK:
					return json.data.get("best_time", 0.0)
				else:
					printerr("Error: Invalid JSON in save file: ", json.get_error_message())
					reset_game()
		else:
			printerr("Error: Could not open save file for reading")
			reset_game()
	return 0.0

func get_clicked_cats() -> Array:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			if content.strip_edges() != "":
				var json = JSON.new()
				var error = json.parse(content)
				if error == OK:
					return json.data.get("clicked_cats", [])
				else:
					printerr("Error: Invalid JSON in save file: ", json.get_error_message())
					reset_game()
		else:
			printerr("Error: Could not open save file for reading")
			reset_game()
	return []

func get_game_completed() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			if content.strip_edges() != "":
				var json = JSON.new()
				var error = json.parse(content)
				if error == OK:
					return json.data.get("game_completed", false)
				else:
					printerr("Error: Invalid JSON in save file: ", json.get_error_message())
					reset_game()
		else:
			printerr("Error: Could not open save file for reading")
			reset_game()
	return false

func set_game_completed(completed: bool):
	var data = {}
	if FileAccess.file_exists(SAVE_PATH):
		var read_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if read_file:
			var content = read_file.get_as_text()
			read_file.close()
			if content.strip_edges() != "":
				var json = JSON.new()
				var error = json.parse(content)
				if error == OK:
					data = json.data
				else:
					printerr("Error: Invalid JSON in save file, resetting data: ", json.get_error_message())
					data = {
						"best_time": 0.0,
						"high_score": 0,
						"clicked_cats": [],
						"game_completed": false,
						"stopwatch_running": true
					}
		else:
			printerr("Error: Could not open save file for reading")
			data = {
				"best_time": 0.0,
				"high_score": 0,
				"clicked_cats": [],
				"game_completed": false,
				"stopwatch_running": true
			}
	else:
		data = {
			"best_time": 0.0,
			"high_score": 0,
			"clicked_cats": [],
			"game_completed": false,
			"stopwatch_running": true
		}
	
	data["game_completed"] = completed
	var write_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file:
		write_file.store_string(JSON.stringify(data, "\t"))
		write_file.close()
	else:
		printerr("Error: Could not open save file for writing at %s" % SAVE_PATH)

func get_stopwatch_running() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			if content.strip_edges() != "":
				var json = JSON.new()
				var error = json.parse(content)
				if error == OK:
					return json.data.get("stopwatch_running", not json.data.get("game_completed", false))
				else:
					printerr("Error: Invalid JSON in save file: ", json.get_error_message())
					reset_game()
		else:
			printerr("Error: Could not open save file for reading")
			reset_game()
	return true

func set_stopwatch_running(running: bool):
	var data = {}
	if FileAccess.file_exists(SAVE_PATH):
		var read_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if read_file:
			var content = read_file.get_as_text()
			read_file.close()
			if content.strip_edges() != "":
				var json = JSON.new()
				var error = json.parse(content)
				if error == OK:
					data = json.data
				else:
					printerr("Error: Invalid JSON in save file, resetting data: ", json.get_error_message())
					data = {
						"best_time": 0.0,
						"high_score": 0,
						"clicked_cats": [],
						"game_completed": false,
						"stopwatch_running": true
					}
		else:
			printerr("Error: Could not open save file for reading")
			data = {
				"best_time": 0.0,
				"high_score": 0,
				"clicked_cats": [],
				"game_completed": false,
				"stopwatch_running": true
			}
	else:
		data = {
			"best_time": 0.0,
			"high_score": 0,
			"clicked_cats": [],
			"game_completed": false,
			"stopwatch_running": true
		}
	
	data["stopwatch_running"] = running
	var write_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file:
		write_file.store_string(JSON.stringify(data, "\t"))
		write_file.close()
	else:
		printerr("Error: Could not open save file for writing at %s" % SAVE_PATH)

func reset_game():
	var default_data = {
		"best_time": 0.0,
		"high_score": 0,
		"clicked_cats": [],
		"game_completed": false,
		"stopwatch_running": true
	}
	var write_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file:
		write_file.store_string(JSON.stringify(default_data, "\t"))
		write_file.close()
	else:
		if FileAccess.file_exists(SAVE_PATH):
			var dir = DirAccess.open("user://")
			if dir:
				var err = dir.remove("savegame.json")
				if err != OK:
					printerr("Error: Could not delete save file at %s. Error code: %s" % [SAVE_PATH, err])
			write_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
			if write_file:
				write_file.store_string(JSON.stringify(default_data, "\t"))
				write_file.close()
			else:
				printerr("Error: Could not create save file after deletion at %s" % SAVE_PATH)
		else:
			printerr("Error: Could not open save file for writing at %s" % SAVE_PATH)

extends Node

const SAVE_PATH = "user://savegame.json"

func save_game(time: float, score: int, clicked_cats: Array):
	var data = {}
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		data = JSON.parse_string(file.get_as_text())
		file.close()
	data["best_time"] = min(data.get("best_time", time), time)  # Keep the lowest time
	data["high_score"] = max(data.get("high_score", score), score)  # Keep the highest score
	data["clicked_cats"] = clicked_cats
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		print("Error: Could not open save file for writing")

func get_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			file.close()
			return data.get("high_score", 0)
	return 0

func get_best_time():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			file.close()
			return data.get("best_time", 0.0)
	return 0.0

func get_clicked_cats():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			file.close()
			return data.get("clicked_cats", [])
	return []

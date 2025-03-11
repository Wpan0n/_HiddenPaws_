# Updated SaveGame.gd
extends Node

func save_game(time, score, clicked_cats):  # Modified: Added clicked_cats parameter
	var data = {
		"best_time": time,
		"high_score": score,
		"clicked_cats": clicked_cats  # New: Save the clicked cats list
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func get_high_score():
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data.get("high_score", 0)
	return 0

func get_best_time():
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data.get("best_time", 0.0)
	return 0.0

func get_clicked_cats():  # New: Retrieve clicked cats
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data.get("clicked_cats", [])
	return []

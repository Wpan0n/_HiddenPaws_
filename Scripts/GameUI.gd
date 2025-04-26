extends Control

var score = 0  # Tracks number of cats clicked
var max_score = 100
var time_elapsed = 0.0  # Tracks elapsed time in seconds
var is_game_running = false
var clicked_cats = []  # Tracks which cats were clicked
var is_fireworks_active = false  # Track if fireworks are running

@onready var scoreLabel = $Score
@onready var score_sound_player = $"../../ScoreSoundPlayer"
@onready var colorRect = $"../../Fireworks"
@onready var hooray_sfx = $"../../Hooray_EndGame"
@onready var stopwatch = $Score/Stopwatch
@onready var fireworks_timer = Timer.new()

func _ready():
	add_to_group("game_ui")
	fireworks_timer.one_shot = true
	fireworks_timer.name = "FireworksTimer"
	add_child(fireworks_timer)
	fireworks_timer.timeout.connect(_on_fireworks_timer_timeout)
	
	var game_completed = false
	if SaveGame:
		score = SaveGame.get_high_score()
		time_elapsed = SaveGame.get_best_time()
		clicked_cats = SaveGame.get_clicked_cats()
		game_completed = SaveGame.get_game_completed()
		var stopwatch_running = SaveGame.get_stopwatch_running()
		is_game_running = stopwatch_running and not game_completed
		if game_completed or not stopwatch_running:
			if stopwatch and stopwatch.has_method("stop_timer"):
				stopwatch.stop_timer()
		else:
			if stopwatch and stopwatch.has_method("start_timer"):
				stopwatch.start_timer()
	else:
		printerr("Error: SaveGame singleton not found!")
	
	if stopwatch:
		if stopwatch.has_method("set_time_elapsed"):
			stopwatch.set_time_elapsed(time_elapsed)
			# Delay to ensure node is ready
			await get_tree().process_frame
			update_stopwatch_display()
			stopwatch.text = "%02d:%02d:%03d" % [int(time_elapsed / 60), int(time_elapsed) % 60, int((time_elapsed - int(time_elapsed)) * 1000)]
			print("GameUI: Loaded time_elapsed=", time_elapsed, " Forced stopwatch text=", stopwatch.text)
		else:
			printerr("Error: Stopwatch missing set_time_elapsed method")
	else:
		printerr("Error: Stopwatch node not found at $Score/Stopwatch")
	
	update_score_label()
	
	var sprite_group = get_tree().get_nodes_in_group("sprite_group")
	if sprite_group.size() != max_score:
		printerr("Warning: Found ", sprite_group.size(), " sprites in sprite_group, expected ", max_score)
	for child in sprite_group:
		if child is Sprite2D:
			if not child.sprite_color_changed.is_connected(_on_sprite_color_changed.bind(child)):
				var err = child.sprite_color_changed.connect(_on_sprite_color_changed.bind(child))
				if err != OK:
					printerr("Error: Failed to connect sprite_color_changed for ", child.name, " Error: ", err)
			if child.name in clicked_cats:
				child.modulate = Color.GRAY
			else:
				child.modulate = Color.WHITE
	
	if stopwatch:
		stopwatch.current_score = score
	else:
		printerr("Error: Stopwatch node not found.")

func _process(delta: float) -> void:
	if is_game_running:
		time_elapsed += delta
		if stopwatch:
			if stopwatch.has_method("set_time_elapsed"):
				stopwatch.set_time_elapsed(time_elapsed)
				update_stopwatch_display()
			else:
				printerr("Error: Stopwatch missing set_time_elapsed method")
		else:
			printerr("Error: Stopwatch node not found")
		var save_timer = 0.0
		save_timer += delta
		if save_timer >= 1.0:
			save_game_state()
			save_timer = 0.0

func _on_sprite_color_changed(sprite: Sprite2D):
	if not sprite.name in clicked_cats and score < max_score:
		print("Sprite clicked: ", sprite.name, " Incrementing score from ", score)
		score += 1
		clicked_cats.append(sprite.name)
		sprite.modulate = Color.GRAY
		save_game_state()
	else:
		print("Sprite ", sprite.name, " not counted: already clicked=", sprite.name in clicked_cats, " score>=max_score=", score >= max_score)
	update_score_label()
	if stopwatch:
		stopwatch.current_score = score
	else:
		printerr("Error: Stopwatch node not found.")

	if score >= max_score and not SaveGame.get_game_completed():
		print("Game complete! Stopping timer")
		is_game_running = false
		if stopwatch:
			if stopwatch.has_method("stop_timer"):
				stopwatch.stop_timer()
				update_stopwatch_display()
			else:
				printerr("Error: Stopwatch missing stop_timer method")
		else:
			printerr("Error: Stopwatch node not found.")
		SaveGame.set_game_completed(true)
		SaveGame.set_stopwatch_running(false)
		save_game_state()
		play_score_sound()

	if score == max_score and not is_fireworks_active:
		is_fireworks_active = true
		colorRect.visible = true
		fireworks_timer.start(15.0)
	else:
		colorRect.visible = false

func update_score_label():
	if scoreLabel:
		scoreLabel.text = "%d/%d" % [score, max_score]
	else:
		printerr("Error: ScoreLabel node not found")

func update_stopwatch_display():
	if stopwatch:
		var minutes = int(time_elapsed / 60)
		var seconds = int(time_elapsed) % 60
		var milliseconds = int((time_elapsed - int(time_elapsed)) * 1000)
		stopwatch.text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
	else:
		printerr("Error: Stopwatch node not found")

func play_score_sound():
	if score_sound_player:
		score_sound_player.play()
		if score_sound_player.is_playing():
			play_hooray_sfx()
	else:
		printerr("Error: Score sound player not found")

func _on_fireworks_timer_timeout():
	if colorRect:
		colorRect.visible = false
	is_fireworks_active = false

func play_hooray_sfx():
	if hooray_sfx:
		hooray_sfx.play()
	else:
		printerr("Error: Hooray sound effect not found")

func save_and_exit():
	is_game_running = false
	save_game_state()

func save_game_state():
	if SaveGame:
		SaveGame.save_game(time_elapsed, score, clicked_cats)
	else:
		printerr("Error: SaveGame singleton not found!")

func reset_game_state():
	score = 0
	time_elapsed = 0.0
	clicked_cats = []
	
	update_score_label()
	if stopwatch:
		if stopwatch.has_method("set_time_elapsed"):
			stopwatch.set_time_elapsed(time_elapsed)
			update_stopwatch_display()
		else:
			printerr("Error: Stopwatch missing set_time_elapsed method")
	else:
		printerr("Error: Stopwatch node not found")
	
	for child in get_tree().get_nodes_in_group("sprite_group"):
		if child is Sprite2D:
			child.modulate = Color.WHITE
	
	SaveGame.set_game_completed(false)
	SaveGame.set_stopwatch_running(true)
	is_game_running = true
	if stopwatch and stopwatch.has_method("start_timer"):
		stopwatch.start_timer()
		print("GameUI: Stopwatch started after reset")

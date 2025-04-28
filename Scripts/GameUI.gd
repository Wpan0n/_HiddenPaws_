extends Control

var score = 0  # Tracks number of cats clicked
var max_score = 100  # Number of interactive sprites (clickable "cats")
var time_elapsed = 0.0  # Tracks elapsed time in seconds
var is_game_running = false
var clicked_cats = []  # Tracks which cats were clicked
var is_fireworks_active = false  # Track if fireworks are running
var last_displayed_time = -1.0  # To reduce stopwatch update frequency

# List of sprite names that are non-interactive (e.g., background)
var non_interactive_sprites = ["Sprite2D101", "Sprite2D102"]  # Adjust these names if needed

@onready var scoreLabel = $Score
@onready var score_sound_player = $"../../ScoreSoundPlayer"
@onready var colorRect = $"../../Fireworks"
@onready var hooray_sfx = $"../../Hooray_EndGame"
@onready var stopwatch = $Score/Stopwatch
@onready var fireworks_timer = Timer.new()

func _ready():
	add_to_group("game_ui")
	# Set up fireworks timer
	fireworks_timer.one_shot = true
	fireworks_timer.name = "FireworksTimer"
	add_child(fireworks_timer)
	fireworks_timer.timeout.connect(_on_fireworks_timer_timeout)
	
	# Load saved game state
	if SaveGame:
		if SaveGame.has_method("get_high_score"):
			score = SaveGame.get_high_score()
		if SaveGame.has_method("get_best_time"):
			time_elapsed = SaveGame.get_best_time()
		if SaveGame.has_method("get_clicked_cats"):
			clicked_cats = SaveGame.get_clicked_cats()
		var game_completed = SaveGame.get_game_completed() if SaveGame.has_method("get_game_completed") else false
		var stopwatch_running = SaveGame.get_stopwatch_running() if SaveGame.has_method("get_stopwatch_running") else true
		is_game_running = stopwatch_running and not game_completed
	else:
		printerr("Error: SaveGame singleton not found!")
	
	# Initialize stopwatch
	if stopwatch:
		if stopwatch.has_method("set_time_elapsed"):
			stopwatch.set_time_elapsed(time_elapsed)
			update_stopwatch_display()
		else:
			printerr("Error: Stopwatch missing set_time_elapsed method")
	else:
		printerr("Error: Stopwatch node not found at $Score/Stopwatch")
	
	update_score_label()
	
	# Verify and connect sprites
	var sprites = get_tree().get_nodes_in_group("sprite_group")
	# Count only interactive sprites for validation
	var interactive_sprites = []
	for sprite in sprites:
		if sprite is Sprite2D and sprite.name not in non_interactive_sprites:
			interactive_sprites.append(sprite)
	
	# Check if the number of interactive sprites matches max_score
	if interactive_sprites.size() != max_score:
		printerr("Warning: Found ", interactive_sprites.size(), " interactive sprites in sprite_group, expected ", max_score)
		var sprite_names = []
		for sprite in sprites:
			if sprite is Sprite2D:
				sprite_names.append(sprite.name)
		printerr("All sprites in sprite_group: ", sprite_names)
	else:
		print("GameUI: Found ", interactive_sprites.size(), " interactive sprites in sprite_group as expected (total sprites: ", sprites.size(), ")")
	
	# Connect signals and set initial colors only for interactive sprites
	for sprite in interactive_sprites:
		if not sprite.sprite_color_changed.is_connected(_on_sprite_color_changed):
			var err = sprite.sprite_color_changed.connect(_on_sprite_color_changed.bind(sprite))
			if err != OK:
				printerr("Error: Failed to connect sprite_color_changed for ", sprite.name, " Error: ", err)
		sprite.modulate = Color.GRAY if sprite.name in clicked_cats else Color.WHITE

func _process(delta: float) -> void:
	if is_game_running:
		time_elapsed += delta
		if stopwatch and stopwatch.has_method("set_time_elapsed"):
			stopwatch.set_time_elapsed(time_elapsed)
			# Update display only if the millisecond value changes
			var current_ms = int(time_elapsed * 1000)
			if current_ms != last_displayed_time:
				update_stopwatch_display()
				last_displayed_time = current_ms
		else:
			printerr("Error: Stopwatch missing set_time_elapsed method")
		# Save game state every second
		if fmod(time_elapsed, 1.0) < delta:
			save_game_state()

func _on_sprite_color_changed(sprite: Sprite2D):
	if sprite.name not in clicked_cats and score < max_score:
		# Ensure only interactive sprites increment the score
		if sprite.name in non_interactive_sprites:
			return  # Skip non-interactive sprites
		score += 1
		clicked_cats.append(sprite.name)
		sprite.modulate = Color.GRAY
		save_game_state()
	update_score_label()
	if score >= max_score and not SaveGame.get_game_completed():
		is_game_running = false
		if SaveGame.has_method("set_game_completed"):
			SaveGame.set_game_completed(true)
		if SaveGame.has_method("set_stopwatch_running"):
			SaveGame.set_stopwatch_running(false)
		save_game_state()
		update_stopwatch_display()
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

func save_game_state():
	if SaveGame and SaveGame.has_method("save_game"):
		SaveGame.save_game(time_elapsed, score, clicked_cats)
	else:
		printerr("Error: SaveGame singleton not found or missing save_game method!")

func reset_game_state():
	score = 0
	time_elapsed = 0.0
	clicked_cats.clear()
	is_game_running = true
	is_fireworks_active = false
	if SaveGame:
		if SaveGame.has_method("set_game_completed"):
			SaveGame.set_game_completed(false)
		if SaveGame.has_method("set_stopwatch_running"):
			SaveGame.set_stopwatch_running(true)
		# Use save_game to reset high_score, best_time, and clicked_cats
		if SaveGame.has_method("save_game"):
			SaveGame.save_game(0.0, 0, [])
	else:
		printerr("Error: SaveGame singleton not found!")
	if stopwatch:
		if stopwatch.has_method("set_time_elapsed"):
			stopwatch.set_time_elapsed(0.0)
		update_stopwatch_display()
	update_score_label()
	# Reset sprite colors, excluding non-interactive sprites
	var sprites = get_tree().get_nodes_in_group("sprite_group")
	for sprite in sprites:
		if sprite is Sprite2D and sprite.name not in non_interactive_sprites:
			sprite.modulate = Color.WHITE

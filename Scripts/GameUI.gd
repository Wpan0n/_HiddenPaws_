extends Control

# --- Game State Variables ---
var score: int = 0
var max_score: int = 100  # Updated: 98 interactive sprites (Sprite1 to Sprite100, excluding Sprite62 and Sprite101).
var time_elapsed: float = 0.0
var is_game_running: bool = false
var clicked_cats: Array = []
var is_fireworks_active: bool = false
var last_displayed_time: float = -1.0
var last_stopwatch_update: float = 0.0  # Optimization: Track last stopwatch update time.

# --- Hint Variables ---
var hint_timer: Timer = Timer.new()
var hinted_sprite: Sprite2D = null
var hint_flash_phase: float = 0.0  # Optimization: Use a single timer for flashing.
var original_sprite_scale: Vector2 = Vector2(1.0, 1.0)  # Store the sprite's original scale.
const FLASH_DURATION: float = 0.3  # Duration of each flash cycle (seconds).
const TOTAL_HINT_DURATION: float = 3.0  # Total hint duration (seconds).
const FLASH_CYCLES: int = int(TOTAL_HINT_DURATION / (FLASH_DURATION * 2))  # Number of flash cycles.

# --- Cached Data for Optimization ---
var interactive_sprites: Array = []  # Cache interactive sprites to avoid re-fetching.
var non_interactive_sprites: Array = ["Sprite2D", "HiddenPaw_Scene"]

# --- Node References ---
@onready var scoreLabel: Label = $Score
@onready var score_sound_player = $"../../ScoreSoundPlayer"
@onready var colorRect: ColorRect = $"../../Fireworks"
@onready var hooray_end_game = $"../../Hooray_EndGame"
@onready var stopwatch: Label = $Score/Stopwatch
@onready var fireworks_timer: Timer = Timer.new()
@onready var hint_button = $HintButton


func _ready() -> void:
	add_to_group("game_ui")
	
	# Validate hint_button.
	if not hint_button:
		printerr("Error: HintButton node not found at $HintButton. Check the node path in the scene tree.")
	
	# Set up timers.
	fireworks_timer.one_shot = true
	fireworks_timer.name = "FireworksTimer"
	add_child(fireworks_timer)
	fireworks_timer.timeout.connect(_on_fireworks_timer_timeout)
	
	hint_timer.one_shot = true
	hint_timer.name = "HintTimer"
	add_child(hint_timer)
	hint_timer.timeout.connect(_on_hint_timer_timeout)
	
	# Load saved game state.
	if SaveGame:
		if SaveGame.has_method("get_high_score"):
			score = SaveGame.get_high_score()
		if SaveGame.has_method("get_best_time"):
			time_elapsed = SaveGame.get_best_time()
		if SaveGame.has_method("get_clicked_cats"):
			clicked_cats = SaveGame.get_clicked_cats()
		var game_completed: bool = SaveGame.get_game_completed() if SaveGame.has_method("get_game_completed") else false
		var stopwatch_running: bool = SaveGame.get_stopwatch_running() if SaveGame.has_method("get_stopwatch_running") else true
		is_game_running = stopwatch_running and not game_completed
	else:
		printerr("Error: SaveGame singleton not found!")
	
	# Cache and connect sprites (Optimization: Avoid re-fetching sprites later).
	var sprites: Array = get_tree().get_nodes_in_group("sprite_group")
	var sprite_names: Array = []
	for sprite in sprites:
		if sprite is Sprite2D:
			if sprite.name not in non_interactive_sprites:
				interactive_sprites.append(sprite)
			sprite_names.append(sprite.name)
	
	# Validate sprite count and debug.
	var expected_interactive_sprites: Array = []
	for i in range(1, 101):
		if "Sprite" + str(i) != "Sprite62" and "Sprite" + str(i) != "Sprite101":
			expected_interactive_sprites.append("Sprite" + str(i))
	
	# Debug non-interactive sprites presence.
	for non_interactive in non_interactive_sprites:
		if non_interactive not in sprite_names:
			printerr("Non-interactive sprite ", non_interactive, " not found in sprite_group. Check if it should be in the group.")
	
	# Check for unexpected sprites in sprite_group.
	var expected_sprite_names: Array = expected_interactive_sprites.duplicate()
	expected_sprite_names.append_array(non_interactive_sprites)
	for sprite_name in sprite_names:
		if sprite_name not in expected_sprite_names:
			printerr("Unexpected sprite in sprite_group: ", sprite_name, ". Please remove it from the sprite_group or add it to non_interactive_sprites.")
	
	# Filter clicked_cats to remove non-interactive or invalid sprites.
	var valid_clicked_cats: Array = []
	for cat in clicked_cats:
		if cat in expected_interactive_sprites:
			valid_clicked_cats.append(cat)
		else:
			print("Removing invalid/non-interactive sprite from clicked_cats: ", cat)
	clicked_cats = valid_clicked_cats
	
	# Recalculate score based on valid clicked_cats.
	score = clicked_cats.size()
	
	if interactive_sprites.size() != max_score:
		printerr("Warning: Found ", interactive_sprites.size(), " interactive sprites in sprite_group, expected ", max_score)
		printerr("All sprites in sprite_group: ", sprite_names)
		var missing_sprites: Array = []
		for expected_sprite in expected_interactive_sprites:
			if expected_sprite not in sprite_names:
				missing_sprites.append(expected_sprite)
		if missing_sprites.size() > 0:
			printerr("Missing sprites: ", missing_sprites)
	else:
		print("GameUI: Found ", interactive_sprites.size(), " interactive sprites in sprite_group as expected (total sprites: ", sprites.size(), ")")
	
	# Initialize stopwatch.
	stopwatch.set_time_elapsed(time_elapsed)
	update_stopwatch_display()
	update_score_label()
	
	# Connect sprite signals and set initial colors.
	for sprite in interactive_sprites:
		if not sprite.sprite_color_changed.is_connected(_on_sprite_color_changed):
			var err: int = sprite.sprite_color_changed.connect(_on_sprite_color_changed.bind(sprite))
			if err != OK:
				printerr("Error: Failed to connect sprite_color_changed for ", sprite.name, " Error: ", err)
		sprite.modulate = Color.GRAY if sprite.name in clicked_cats else Color.WHITE

func _process(delta: float) -> void:
	if is_game_running:
		time_elapsed += delta
		# Update stopwatch time.
		stopwatch.set_time_elapsed(time_elapsed)
		
		# Optimization: Only update stopwatch display every 0.1 seconds (100ms).
		last_stopwatch_update += delta
		if last_stopwatch_update >= 0.1:
			var current_ms: int = int(time_elapsed * 1000)
			if current_ms != last_displayed_time:
				update_stopwatch_display()
				last_displayed_time = current_ms
			last_stopwatch_update = 0.0
	
	# Optimization: Handle hint flashing in _process instead of using a separate timer.
	if hinted_sprite and hint_timer.time_left > 0:
		hint_flash_phase += delta / FLASH_DURATION
		var cycle: float = fmod(hint_flash_phase, 1.0)
		if cycle < 0.5:
			hinted_sprite.modulate = Color.RED
		else:
			hinted_sprite.modulate = Color.WHITE
		# Keep the scale at 300% larger than the original scale during the hint.
		hinted_sprite.scale = original_sprite_scale * 3

func _on_sprite_color_changed(sprite: Sprite2D) -> void:
	if sprite.name not in clicked_cats and score < max_score:
		if sprite.name in non_interactive_sprites:
			return
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

func _on_hint_button_pressed() -> void:
	if hint_timer.time_left > 0:
		return
	
	# Optimization: Use cached interactive_sprites instead of re-fetching.
	var unclicked_sprites: Array = []
	for sprite in interactive_sprites:
		if sprite.name not in clicked_cats:
			unclicked_sprites.append(sprite)
	
	if unclicked_sprites.size() > 0:
		hinted_sprite = unclicked_sprites[randi() % unclicked_sprites.size()]
		# Store the original scale of the sprite.
		original_sprite_scale = hinted_sprite.scale
		hint_flash_phase = 0.0
		hinted_sprite.modulate = Color.RED
		hinted_sprite.scale = original_sprite_scale * 1.5  # 50% larger than original.
		hint_timer.start(TOTAL_HINT_DURATION)
	else:
		print("No unclicked sprites available for hint.")

func _on_hint_timer_timeout() -> void:
	if hinted_sprite:
		if hinted_sprite.name not in clicked_cats:
			hinted_sprite.modulate = Color.WHITE
		else:
			hinted_sprite.modulate = Color.GRAY
		hinted_sprite.scale = original_sprite_scale  # Revert to original scale.
	hinted_sprite = null
	hint_flash_phase = 0.0

func update_score_label() -> void:
	if scoreLabel:
		scoreLabel.text = "%d/%d" % [score, max_score]
	else:
		printerr("Error: ScoreLabel node not found")

func update_stopwatch_display() -> void:
	if stopwatch:
		var minutes: int = int(time_elapsed / 60)
		var seconds: int = int(time_elapsed) % 60
		var milliseconds: int = int((time_elapsed - int(time_elapsed)) * 1000)
		stopwatch.text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
	else:
		printerr("Error: Stopwatch node not found")

func play_score_sound() -> void:
	if score_sound_player:
		score_sound_player.play()
		if score_sound_player.is_playing():
			play_hooray_sfx()
	else:
		printerr("Error: Score sound player not found")

func _on_fireworks_timer_timeout() -> void:
	if colorRect:
		colorRect.visible = false
	is_fireworks_active = false

func play_hooray_sfx() -> void:
	if hooray_end_game:
		hooray_end_game.play()
	else:
		printerr("Error: Hooray sound effect not found")

func save_game_state() -> void:
	if SaveGame and SaveGame.has_method("save_game"):
		SaveGame.save_game(time_elapsed, score, clicked_cats)
	else:
		printerr("Error: SaveGame singleton not found or missing save_game method!")

func reset_game_state() -> void:
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
		if SaveGame.has_method("save_game"):
			SaveGame.save_game(0.0, 0, [])
	else:
		printerr("Error: SaveGame singleton not found!")
	if stopwatch:
		stopwatch.set_time_elapsed(0.0)
		update_stopwatch_display()
	update_score_label()
	
	# Optimization: Use cached interactive_sprites.
	for sprite in interactive_sprites:
		sprite.modulate = Color.WHITE

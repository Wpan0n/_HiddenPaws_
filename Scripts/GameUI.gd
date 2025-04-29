extends Control

# --- What This Script Does ---
# This script controls the game’s user interface (UI), like the score display and stopwatch.
# It keeps track of how many cats (sprites) the player has clicked, updates the score,
# plays sounds when the game is won, and saves the game progress.
# It also manages a hint button that makes an unclicked sprite flash for a second.

# --- Game State Variables ---
# These keep track of the game’s progress.
var score = 0  # How many cats the player has clicked.
var max_score = 100  # The total number of cats to click to win (100 cat sprites).
var time_elapsed = 0.0  # How much time has passed (in seconds) while the game is running.
var is_game_running = false  # True when the game is active, False when paused or finished.
var clicked_cats = []  # A list of the names of cats that have been clicked.
var is_fireworks_active = false  # True when the fireworks animation is playing (after winning).
var last_displayed_time = -1.0  # Helps reduce how often the stopwatch updates to improve performance.

# --- Hint Variables ---
# These manage the hint functionality.
var hint_timer: Timer = null  # A timer to control how long a sprite flashes.
var hinted_sprite: Sprite2D = null  # The sprite currently being hinted.

# --- Non-Interactive Sprites ---
# These are sprites that shouldn’t be clickable (like the stopwatch icon).
var non_interactive_sprites = ["Sprite101"]  # Sprite101 is the stopwatch icon, not a cat.

# --- Node References ---
# These are connections to other parts of the game (like the score text and sound effects).
@onready var scoreLabel = $Score  # The text that shows the score (e.g., "5/100").
@onready var score_sound_player = $"../../ScoreSoundPlayer"  # The sound that plays when you click a cat.
@onready var colorRect = $"../../Fireworks"  # The fireworks animation that plays when you win.
@onready var hooray_sfx = $"../../Hooray_EndGame"  # The "hooray" sound that plays when you win.
@onready var stopwatch = $Score/Stopwatch  # The stopwatch that shows how much time has passed.
@onready var fireworks_timer = Timer.new()  # A timer that controls how long the fireworks play.
@onready var hint_button = $HintButton  # The hint button in the top-right corner.

# --- How This Works When the Game Starts ---
func _ready():
	# This runs when the game starts.
	
	# Add this UI to a group called "game_ui" so other scripts (like pause_menu.gd) can find it.
	add_to_group("game_ui")
	
	# Set up the fireworks timer (it will stop after 15 seconds).
	fireworks_timer.one_shot = true  # This means the timer only runs once.
	fireworks_timer.name = "FireworksTimer"
	add_child(fireworks_timer)  # Add the timer to the game.
	fireworks_timer.timeout.connect(_on_fireworks_timer_timeout)  # When the timer finishes, run _on_fireworks_timer_timeout.
	
	# Set up the hint timer (it will control the flashing duration).
	hint_timer = Timer.new()
	hint_timer.one_shot = true  # The timer only runs once.
	hint_timer.name = "HintTimer"
	add_child(hint_timer)  # Add the timer to the game.
	hint_timer.timeout.connect(_on_hint_timer_timeout)  # When the timer finishes, reset the sprite color.
	
	# Load the saved game progress (like the score and time).
	if SaveGame:
		if SaveGame.has_method("get_high_score"):
			# Load the saved score.
			score = SaveGame.get_high_score()
		if SaveGame.has_method("get_best_time"):
			# Load the saved time.
			time_elapsed = SaveGame.get_best_time()
		if SaveGame.has_method("get_clicked_cats"):
			# Load the list of clicked cats.
			clicked_cats = SaveGame.get_clicked_cats()
		# Check if the game was already completed or if the stopwatch was running.
		var game_completed = SaveGame.get_game_completed() if SaveGame.has_method("get_game_completed") else false
		var stopwatch_running = SaveGame.get_stopwatch_running() if SaveGame.has_method("get_stopwatch_running") else true
		# If the game isn’t completed and the stopwatch was running, keep the game active.
		is_game_running = stopwatch_running and not game_completed
	else:
		# If SaveGame isn’t found, show an error in the console.
		printerr("Error: SaveGame singleton not found!")
	
	# Set up the stopwatch with the saved time.
	if stopwatch:
		if stopwatch.has_method("set_time_elapsed"):
			# Set the stopwatch to the saved time and update its display.
			stopwatch.set_time_elapsed(time_elapsed)
			update_stopwatch_display()
		else:
			# If the stopwatch is missing a required function, show an error.
			printerr("Error: Stopwatch missing set_time_elapsed method")
	else:
		# If the stopwatch isn’t found, show an error.
		printerr("Error: Stopwatch node not found at $Score/Stopwatch")
	
	# Update the score text (e.g., "0/100").
	update_score_label()
	
	# Check how many sprites (cats) are in the "sprite_group".
	# We only count the ones that are clickable (not background sprites or the stopwatch icon).
	var sprites = get_tree().get_nodes_in_group("sprite_group")
	# Make a list of only the clickable sprites.
	var interactive_sprites = []
	var sprite_names = []
	for sprite in sprites:
		if sprite is Sprite2D:
			if sprite.name not in non_interactive_sprites:
				# Add clickable sprites to the list.
				interactive_sprites.append(sprite)
			# Keep track of all sprite names for debugging.
			sprite_names.append(sprite.name)
	
	# Check if the number of clickable sprites matches max_score (should be 100).
	if interactive_sprites.size() != max_score:
		# If there aren’t exactly 100 clickable sprites, show a warning.
		printerr("Warning: Found ", interactive_sprites.size(), " interactive sprites in sprite_group, expected ", max_score)
		# List all sprites in the group to help find the problem.
		printerr("All sprites in sprite_group: ", sprite_names)
		# Check for missing sprites in the range Sprite1 to Sprite100.
		var expected_sprites = []
		for i in range(1, 101):  # From Sprite1 to Sprite100.
			expected_sprites.append("Sprite" + str(i))
		var missing_sprites = []
		for expected_sprite in expected_sprites:
			if expected_sprite not in sprite_names:
				missing_sprites.append(expected_sprite)
		if missing_sprites.size() > 0:
			printerr("Missing sprites: ", missing_sprites)
	else:
		# If there are exactly 100 clickable sprites, print a success message.
		print("GameUI: Found ", interactive_sprites.size(), " interactive sprites in sprite_group as expected (total sprites: ", sprites.size(), ")")
	
	# Connect each clickable sprite to this script so we know when it’s clicked.
	# Also, make clicked sprites gray.
	for sprite in interactive_sprites:
		if not sprite.sprite_color_changed.is_connected(_on_sprite_color_changed):
			# Connect the sprite’s click signal to our function.
			var err = sprite.sprite_color_changed.connect(_on_sprite_color_changed.bind(sprite))
			if err != OK:
				# If the connection fails, show an error.
				printerr("Error: Failed to connect sprite_color_changed for ", sprite.name, " Error: ", err)
		# If the sprite was already clicked (loaded from save), make it gray.
		sprite.modulate = Color.GRAY if sprite.name in clicked_cats else Color.WHITE

# --- Update the Game Every Frame ---
func _process(delta: float) -> void:
	# This runs every frame (like 60 times a second).
	# "delta" is the time since the last frame (in seconds).
	
	# If the game is active...
	if is_game_running:
		# Add the time since the last frame to the total time.
		time_elapsed += delta
		if stopwatch and stopwatch.has_method("set_time_elapsed"):
			# Update the stopwatch with the new time.
			stopwatch.set_time_elapsed(time_elapsed)
			# Only update the stopwatch display if the millisecond value changes (to improve performance).
			var current_ms = int(time_elapsed * 1000)
			if current_ms != last_displayed_time:
				update_stopwatch_display()
				last_displayed_time = current_ms
		else:
			# If the stopwatch is missing a required function, show an error.
			printerr("Error: Stopwatch missing set_time_elapsed method")
		# Save the game progress every second.
		if fmod(time_elapsed, 1.0) < delta:
			save_game_state()

# --- When a Sprite (Cat) Is Clicked ---
func _on_sprite_color_changed(sprite: Sprite2D):
	# This runs when a sprite is clicked.
	
	# If this sprite hasn’t been clicked yet and we haven’t reached the max score...
	if sprite.name not in clicked_cats and score < max_score:
		# Make sure this isn’t a non-interactive sprite (like a background).
		if sprite.name in non_interactive_sprites:
			return  # Skip non-interactive sprites.
		# Increase the score by 1.
		score += 1
		# Add the sprite’s name to the list of clicked cats.
		clicked_cats.append(sprite.name)
		# Make the sprite gray to show it’s been clicked.
		sprite.modulate = Color.GRAY
		# Save the game progress.
		save_game_state()
	# Update the score text (e.g., "1/100").
	update_score_label()
	# If the player has clicked all 100 cats and the game isn’t marked as completed...
	if score >= max_score and not SaveGame.get_game_completed():
		# Stop the game.
		is_game_running = false
		if SaveGame.has_method("set_game_completed"):
			# Mark the game as completed in the save file.
			SaveGame.set_game_completed(true)
		if SaveGame.has_method("set_stopwatch_running"):
			# Mark the stopwatch as stopped in the save file.
			SaveGame.set_stopwatch_running(false)
		# Save the game progress.
		save_game_state()
		# Update the stopwatch display.
		update_stopwatch_display()
		# Play the winning sound.
		play_score_sound()
	
	# If the player has exactly 100 points and the fireworks aren’t already playing...
	if score == max_score and not is_fireworks_active:
		# Start the fireworks animation.
		is_fireworks_active = true
		colorRect.visible = true
		# Play the fireworks for 15 seconds.
		fireworks_timer.start(15.0)
	else:
		# Hide the fireworks if they shouldn’t be playing.
		colorRect.visible = false

# --- When the Hint Button Is Pressed ---
func _on_hint_button_pressed():
	# This runs when the player clicks the Hint button.
	
	# If a hint is already active, don’t start another one.
	if hint_timer.time_left > 0:
		return
	
	# Get all sprites in the "sprite_group".
	var sprites = get_tree().get_nodes_in_group("sprite_group")
	var unclicked_sprites = []
	
	# Find all unclicked sprites (not in clicked_cats and not non-interactive).
	for sprite in sprites:
		if sprite is Sprite2D and sprite.name not in clicked_cats and sprite.name not in non_interactive_sprites:
			unclicked_sprites.append(sprite)
	
	# If there are unclicked sprites, pick one to hint.
	if unclicked_sprites.size() > 0:
		# Pick a random unclicked sprite.
		hinted_sprite = unclicked_sprites[randi() % unclicked_sprites.size()]
		# Make the sprite flash yellow.
		hinted_sprite.modulate = Color.YELLOW
		# Start the hint timer (1 second).
		hint_timer.start(1.0)
	else:
		# If all sprites are clicked, do nothing.
		print("No unclicked sprites available for hint.")

# --- When the Hint Timer Finishes ---
func _on_hint_timer_timeout():
	# This runs when the hint timer (1 second) finishes.
	
	# Reset the hinted sprite’s color to white (if it hasn’t been clicked).
	if hinted_sprite and hinted_sprite.name not in clicked_cats:
		hinted_sprite.modulate = Color.WHITE
	# Clear the hinted sprite reference.
	hinted_sprite = null

# --- Update the Score Text ---
func update_score_label():
	# This updates the score text on the screen (e.g., "5/100").
	if scoreLabel:
		scoreLabel.text = "%d/%d" % [score, max_score]
	else:
		# If the score label isn’t found, show an error.
		printerr("Error: ScoreLabel node not found")

# --- Update the Stopwatch Display ---
func update_stopwatch_display():
	# This updates the stopwatch text to show the current time (e.g., "01:23:456").
	if stopwatch:
		# Calculate minutes, seconds, and milliseconds from the total time.
		var minutes = int(time_elapsed / 60)
		var seconds = int(time_elapsed) % 60
		var milliseconds = int((time_elapsed - int(time_elapsed)) * 1000)
		# Show the time in the format "MM:SS:MMM".
		stopwatch.text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
	else:
		# If the stopwatch isn’t found, show an error.
		printerr("Error: Stopwatch node not found")

# --- Play the Score Sound ---
func play_score_sound():
	# This plays a sound when the player wins the game.
	if score_sound_player:
		# Play the score sound.
		score_sound_player.play()
		# If the sound is playing, also play the "hooray" sound.
		if score_sound_player.is_playing():
			play_hooray_sfx()
	else:
		# If the sound player isn’t found, show an error.
		printerr("Error: Score sound player not found")

# --- When the Fireworks Timer Finishes ---
func _on_fireworks_timer_timeout():
	# This runs when the fireworks timer (15 seconds) is done.
	if colorRect:
		# Hide the fireworks.
		colorRect.visible = false
	# Mark the fireworks as not active.
	is_fireworks_active = false

# --- Play the Hooray Sound ---
func play_hooray_sfx():
	# This plays the "hooray" sound when the player wins.
	if hooray_sfx:
		hooray_sfx.play()
	else:
		# If the sound effect isn’t found, show an error.
		printerr("Error: Hooray sound effect not found")

# --- Save the Game Progress ---
func save_game_state():
	# This saves the game progress (score, time, and clicked cats).
	if SaveGame and SaveGame.has_method("save_game"):
		SaveGame.save_game(time_elapsed, score, clicked_cats)
	else:
		# If SaveGame isn’t found, show an error.
		printerr("Error: SaveGame singleton not found or missing save_game method!")

# --- Reset the Game’s UI ---
func reset_game_state():
	# This resets the game’s UI to start a new game.
	
	# Set the score back to 0.
	score = 0
	# Set the time back to 0.
	time_elapsed = 0.0
	# Clear the list of clicked cats.
	clicked_cats.clear()
	# Mark the game as running (active).
	is_game_running = true
	# Hide the fireworks.
	is_fireworks_active = false
	# Save the reset state.
	if SaveGame:
		if SaveGame.has_method("set_game_completed"):
			# Mark the game as not completed.
			SaveGame.set_game_completed(false)
		if SaveGame.has_method("set_stopwatch_running"):
			# Mark the stopwatch as running.
			SaveGame.set_stopwatch_running(true)
		# Use save_game to reset high_score, best_time, and clicked_cats.
		if SaveGame.has_method("save_game"):
			SaveGame.save_game(0.0, 0, [])
	else:
		# If SaveGame isn’t found, show an error.
		printerr("Error: SaveGame singleton not found!")
	# Reset the stopwatch display.
	if stopwatch:
		if stopwatch.has_method("set_time_elapsed"):
			# Set the stopwatch time to 0.
			stopwatch.set_time_elapsed(0.0)
		# Update the stopwatch display.
		update_stopwatch_display()
	# Update the score text (should show "0/100").
	update_score_label()
	# Reset sprite colors, excluding non-interactive sprites.
	var sprites = get_tree().get_nodes_in_group("sprite_group")
	for sprite in sprites:
		if sprite is Sprite2D and sprite.name not in non_interactive_sprites:
			# Make the sprite white again (not clicked).
			sprite.modulate = Color.WHITE

# --- How to Fix Common Issues ---
# 1. If the hint button doesn’t work:
#    - Make sure the HintButton node exists in the scene (path: GameUI/HintButton).
#      Open the scene (res://Scenes/MainGame.tscn), find the HintButton node under GameUI, and check its path.
#    - Make sure the button’s "pressed" signal is connected to _on_hint_button_pressed.
#      In the editor, select HintButton, go to Node dock > Signals tab, and check that "pressed" is connected.
# 2. If the sprite doesn’t flash when using the hint:
#    - Make sure the sprites are in the "sprite_group" (Node dock > Groups tab > Check for "sprite_group").
#    - Make sure the sprite hasn’t already been clicked (it should be white, not gray).
# 3. If the fireworks don’t play when you win:
#    - Make sure the Fireworks node exists in the scene (path: "../../Fireworks").
#      Open the scene, find the Fireworks node (likely a ColorRect), and check its path.
#    - Check that the fireworks_timer is working (it should play for 15 seconds).
# 4. If the game is slow:
#    - Open the Godot editor, go to Debug > Profiler, and click Start Profiling while playing.
#      If you see "_process" taking a long time (like more than 5ms), let me know, and we can make it faster.

extends Control

# --- What This Script Does ---
# This script controls the game’s user interface (UI), like the score display and stopwatch.
# It keeps track of how many cats (sprites) the player has clicked, updates the score,
# plays sounds when the game is won, and saves the game progress.
# It also checks that there are exactly 100 clickable cats in the game.

# --- Game State Variables ---
# These keep track of the game’s progress.
var score = 0  # How many cats the player has clicked.
var max_score = 100  # The total number of cats the player needs to click to win (should be 100).
var time_elapsed = 0.0  # How much time has passed (in seconds) while the game is running.
var is_game_running = false  # True when the game is active, False when paused or finished.
var clicked_cats = []  # A list of the names of cats that have been clicked.
var is_fireworks_active = false  # True when the fireworks animation is playing (after winning).
var last_displayed_time = -1.0  # Helps reduce how often the stopwatch updates to improve performance.

# --- Non-Interactive Sprites ---
# These are sprites that shouldn’t be clickable (like background images).
# We exclude them from the score and clicking logic.
var non_interactive_sprites = ["Sprite2D101", "Sprite2D102"]  # Adjust these names if needed.

# --- Node References ---
# These are connections to other parts of the game (like the score text and sound effects).
@onready var scoreLabel = $Score  # The text that shows the score (e.g., "5/100").
@onready var score_sound_player = $"../../ScoreSoundPlayer"  # The sound that plays when you click a cat.
@onready var colorRect = $"../../Fireworks"  # The fireworks animation that plays when you win.
@onready var hooray_sfx = $"../../Hooray_EndGame"  # The "hooray" sound that plays when you win.
@onready var stopwatch = $Score/Stopwatch  # The stopwatch that shows how much time has passed.
@onready var fireworks_timer = Timer.new()  # A timer that controls how long the fireworks play.

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
	# We only count the ones that are clickable (not background sprites).
	var sprites = get_tree().get_nodes_in_group("sprite_group")
	# Make a list of only the clickable sprites.
	var interactive_sprites = []
	for sprite in sprites:
		if sprite is Sprite2D and sprite.name not in non_interactive_sprites:
			# Add clickable sprites to the list.
			interactive_sprites.append(sprite)
	
	# Check if the number of clickable sprites matches max_score (should be 100).
	if interactive_sprites.size() != max_score:
		# If there aren’t exactly 100 clickable sprites, show a warning.
		printerr("Warning: Found ", interactive_sprites.size(), " interactive sprites in sprite_group, expected ", max_score)
		# List all sprites in the group to help find the problem.
		var sprite_names = []
		for sprite in sprites:
			if sprite is Sprite2D:
				sprite_names.append(sprite.name)
		printerr("All sprites in sprite_group: ", sprite_names)
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
# 1. If the game says "Found 102 sprites in sprite_group, expected 100":
#    - This means there are too many clickable sprites in the "sprite_group".
#    - The script already skips "Sprite2D101" and "Sprite2D102" (listed in non_interactive_sprites).
#    - Open the game scene in the Godot editor (File > Open > res://Scenes/MainGame.tscn).
#    - Look at the list of sprite names in the warning (e.g., "Sprite2D2" to "Sprite2D102").
#    - Check if "Sprite2D1" is in the Scene tree. If it’s there but not in the list, add it to "sprite_group":
#      - Click "Sprite2D1", go to Node dock > Groups tab, type "sprite_group", and click "+".
#    - If "Sprite2D1" is missing, add a new Sprite2D node (right-click in Scene tree > Add Node > Sprite2D).
#      Name it "Sprite2D1", set its texture to the same cat image, and add it to "sprite_group".
#    - If there are other extra sprites, add their names to the "non_interactive_sprites" list at the top of this script.
# 2. If the score doesn’t update when you click a cat:
#    - Make sure the sprite has the Cat_Sprite.gd script attached (click the sprite in the Scene tree, check the script in the Inspector).
#    - Make sure the sprite is in the "sprite_group" (Node dock > Groups tab > Check for "sprite_group").
#    - Make sure the sprite isn’t in the "non_interactive_sprites" list (if it is, remove it from that list).
# 3. If the fireworks don’t play when you win:
#    - Make sure the Fireworks node exists in the scene (path: "../../Fireworks").
#      Open the scene, find the Fireworks node (likely a ColorRect), and check its path.
#    - Check that the fireworks_timer is working (it should play for 15 seconds).
# 4. If the game is slow:
#    - Open the Godot editor, go to Debug > Profiler, and click Start Profiling while playing.
#      If you see "_process" taking a long time (like more than 5ms), let me know, and we can make it faster.

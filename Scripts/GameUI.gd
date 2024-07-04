extends Control

var score = 0
var max_score = 100
@onready var scoreLabel = $Score
@onready var score_sound_player = $"../../ScoreSoundPlayer"
@onready var colorRect = $"../../Fireworks"  # Reference to your ColorRect node
@onready var hooray_sfx = $"../../Hooray_EndGame" # Reference to the AudioStreamPlayer Hooray Sfx
@onready var stopwatch = $Score/Stopwatch  # Adjust this path to your Stopwatch node

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Ready called")  # Debugging statement
	# Set the initial score text
	update_score_label()
	# Connect the "sprite_color_changed" signal emitted by the Sprite2D nodes to the "_on_sprite_color_changed" method of this script
	for child in get_tree().get_nodes_in_group("sprite_group"):
		if child is Sprite2D:
			child.sprite_color_changed.connect(_on_sprite_color_changed)
	# Ensure stopwatch node is valid
	if stopwatch:
		stopwatch.current_score = score
	else:
		print("Error: Stopwatch node not found.")

# This method will be called whenever a sprite's color changes
func _on_sprite_color_changed():
	print("Color change detected")  # Add this line to debug
	# Increase the score by one
	score += 1
	print("Score: ", score)  # Debugging statement
	# Update the score label text to display the new score
	update_score_label()
	# Update the score in the stopwatch script if valid
	if stopwatch:
		stopwatch.current_score = score
	else:
		print("Error: Stopwatch node not found.")

	# Check if the score has reached max_score and play sound
	if score >= max_score:
		print("Playing score sound")  # Debugging statement
		play_score_sound()
		# Stop the stopwatch if valid
		if stopwatch:
			stopwatch.stop_timer()
		else:
			print("Error: Stopwatch node not found.")

	# Toggle ColorRect visibility when score reaches max_score
	if score == max_score:
		colorRect.visible = true
		# Call the function to turn off visibility after 15 seconds
		call_deferred("turn_off_color_rect_after_delay")
	else:
		colorRect.visible = false

# Helper method to update the score label text
func update_score_label():
	scoreLabel.text = str(score) + "/" + str(max_score)

# Method to play the score sound and hooray sound if score_sound_player is playing
func play_score_sound():
	if score_sound_player:
		print("Score sound player exists")  # Debugging statement
		score_sound_player.play()
		# Check if hooray_sfx should be played
		if score_sound_player.is_playing():
			play_hooray_sfx()
	else:
		print("Score sound player does not exist")  # Debugging statement

# Function to turn off ColorRect visibility after 15 seconds
func turn_off_color_rect_after_delay():
	var time_elapsed = 0.0
	while time_elapsed < 15:
		await get_tree().process_frame
		time_elapsed += get_process_delta_time()
	colorRect.visible = false

# Function to play the hooray_sfx
func play_hooray_sfx():
	if hooray_sfx:
		print("Playing hooray sound effect")  # Debugging statement
		hooray_sfx.play()
	else:
		print("Hooray sound effect not available")  # Debugging statement

extends Control

var score = 0
var max_score = 100 
@onready var scoreLabel = $Score
@onready var score_sound_player = $"../../ScoreSoundPlayer"  # Reference to the AudioStreamPlayer2D
@onready var colorRect = $"../../Fireworks"  # Reference to your ColorRect node

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Ready called")  # Debugging statement
	# Set the initial score text
	update_score_label()

	# Connect the "sprite_color_changed" signal emitted by the Sprite2D nodes to the "_on_sprite_color_changed" method of this script
	for child in get_tree().get_nodes_in_group("sprite_group"):
		if child is Sprite2D:
			child.sprite_color_changed.connect(_on_sprite_color_changed)

# This method will be called whenever a sprite's color changes
func _on_sprite_color_changed():
	print("Color change detected")  # Add this line to debug
	# Increase the score by one
	score += 1
	print("Score: ", score)  # Debugging statement
	# Update the score label text to display the new score
	update_score_label()
	# Check if the score has reached 100 and play sound
	if score >= max_score:
		print("Playing score sound")  # Debugging statement
		play_score_sound()

	# Toggle ColorRect visibility when score reaches 3
	if score == 100:
		colorRect.visible = true
	else:
		colorRect.visible = false

# Helper method to update the score label text
func update_score_label():
	scoreLabel.text = str(score) + "/" + str(max_score)

# Method to play the score sound
func play_score_sound():
	if score_sound_player:
		print("Score sound player exists")  # Debugging statement
		score_sound_player.play()
	else:
		print("Score sound player does not exist")  # Debugging statement

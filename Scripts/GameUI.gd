extends Control

var score = 0
var max_score = 100
@onready var scoreLabel = $Score

# Called when the node enters the scene tree for the first time.
func _ready():
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
	# Update the score label text to display the new score
	update_score_label()

# Helper method to update the score label text
func update_score_label():
	scoreLabel.text = str(score) + "/" + str(max_score)

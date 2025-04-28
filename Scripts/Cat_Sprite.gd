extends Sprite2D

# --- What This Script Does ---
# This script makes a sprite (like a cat in the game) clickable.
# When the player clicks the sprite, it changes color, plays a sound, and sends a signal to another script (like GameUI.gd) to update the score.

# --- Signal for Clicking ---
# This creates a signal called "sprite_color_changed" that other scripts can listen for.
# It’s like sending a message saying, “Hey, this sprite was clicked!”
signal sprite_color_changed

# --- Node References ---
# This connects to the AudioStreamPlayer node to play a sound when the sprite is clicked.
@onready var audio_player = $"../AudioStreamPlayer"

# --- Click State ---
# This keeps track of whether the sprite has already been clicked.
var clicked = false  # False means it hasn’t been clicked yet, True means it has.

# --- Handle Mouse Clicks ---
func _input(event):
	# This runs whenever the player uses the mouse or keyboard.
	
	# Check if the player clicked the left mouse button.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if the click was on this sprite.
			# "get_local_mouse_position()" finds where the mouse is compared to the sprite.
			# "is_pixel_opaque()" makes sure the click was on a visible part of the sprite (not a transparent area).
			if is_pixel_opaque(get_local_mouse_position()):
				# Print a message to the console to help with debugging.
				print("sprite clicked")
				# Change the sprite’s color to gray to show it’s been clicked.
				# "#bebebe" is a gray color in hex code (a way to write colors).
				modulate = Color("#bebebe")  # Changed to hex color code
				
				# Play a sound to let the player know they clicked the sprite.
				if audio_player:
					audio_player.play()
				else:
					# If the AudioStreamPlayer isn’t found, show an error in the console.
					print("AudioStreamPlayer node not found")
				
				# If the sprite hasn’t been clicked before, send the signal.
				if not clicked:
					emit_signal("sprite_color_changed")
					# Print a message to confirm the signal was sent.
					print("Signal emitted")
					# Mark the sprite as clicked so it doesn’t send the signal again.
					clicked = true

# --- How to Fix Common Issues ---
# 1. If clicking the sprite doesn’t do anything:
#    - Make sure this script is attached to the Sprite2D node in your scene.
#      Open the scene (like res://Scenes/MainGame.tscn), right-click the Sprite2D node, and check its script in the Inspector.
#    - Make sure the sprite is in the "sprite_group" so GameUI.gd can find it.
#      In the editor, select the sprite, go to the Node dock (on the right), click the Groups tab, and add "sprite_group".
#    - Make sure the sprite’s texture has opaque pixels (not all transparent).
#      In the editor, select the sprite, and in the Inspector, check that its texture has visible parts.
# 2. If the sound doesn’t play when clicking:
#    - Make sure there’s an AudioStreamPlayer node in the scene at the path "../AudioStreamPlayer".
#      Open the scene, find the AudioStreamPlayer node (it should be a sibling of the sprite’s parent), and check its name.
#    - Make sure the AudioStreamPlayer has a sound file assigned.
#      Select the AudioStreamPlayer in the editor, and in the Inspector, set its "Stream" property to a sound file (like an MP3 or WAV).
# 3. If the sprite doesn’t change color:
#    - Make sure the color "#bebebe" is correct. You can change it to another color, like "Color.GRAY", if you prefer.
#    - Make sure GameUI.gd is listening for the "sprite_color_changed" signal (it should be connected in GameUI.gd’s "_ready()" function).

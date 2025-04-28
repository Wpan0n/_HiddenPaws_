extends Node2D

# --- What This Script Does ---
# This script is attached to the main game scene (where the player plays the game).
# Right now, it only prints a message when the game starts.
# It can be used to set up the game, like starting the music or resetting the score.

# --- How This Works When the Game Starts ---
func _ready():
	# This runs when the game starts.
	# Print a message to the console to confirm the game scene is ready.
	print("MainGame ready")

# --- How to Fix Common Issues ---
# 1. If the game scene doesn’t load:
#    - Make sure this script is attached to the root node of the MainGame.tscn scene.
#      Open the scene (res://Scenes/MainGame.tscn), right-click the root node (likely a Node2D), and check its script in the Inspector.
#    - Make sure main_menu.gd is pointing to the correct scene file ("res://Scenes/MainGame.tscn").
# 2. If the game doesn’t start properly:
#    - You might want to add setup code here, like starting the level music or resetting the game state.
#    - For example, you could add:
#      - Call "audio_player.play_music_level()" to start the music (if audio_player.gd is in the scene).
#      - Call "GameUI.reset_game_state()" to reset the score and time (if GameUI.gd is in the scene).

extends Node2D

# --- What This Script Does ---
# This script is attached to the main game scene (where the player plays the game).
# It sets up the game on load, but no longer forces reset to allow resuming saved progress.

# --- How This Works When the Game Starts ---
func _ready():
	# This runs when the game starts.
	print("MainGame ready")
	
	# FIXED: Removed unconditional reset—now relies on GameUI._ready() to load state or reset only if completed.
	# This allows resuming partial saves (e.g., 20/100) after menu.
	
	# FIXED: Music handled by AutoLoad—no local call needed.
	var audio_player = get_tree().get_root().get_node_or_null("AudioPlayer")
	if audio_player and audio_player.is_playing():
		print("MainGame: Music already playing (AutoLoad persistent)")
	else:
		printerr("MainGame: Music not playing on load—check AutoLoad _ready()")
	
	# If you have other setup: e.g., camera init, etc.

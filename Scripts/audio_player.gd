extends AudioStreamPlayer

# --- What This Script Does ---
# This script plays the background music for the game’s levels.
# It loads a music file and has functions to play the music with a specific volume.

# --- Preloaded Music File ---
# This loads the music file so the game can play it.
# The file is stored in the "assets" folder and is called "inspiring-technology-143299.mp3".
const level_music = preload("res://assets/Sfx_Music/inspiring-technology-143299.mp3")

# --- Function to Play Music ---
func _play_music(music: AudioStream, volume = 0.0):
	# This function plays a music file with a specific volume.
	
	# If the music we want to play is already playing, don’t do anything (to avoid restarting it).
	if stream == music:
		return
	
	# Set the music to play (like choosing a song on a music player).
	stream = music
	# Set the volume (0.0 is normal, negative numbers make it quieter, positive numbers make it louder).
	volume_db = volume
	
	# Start playing the music.
	play()

# --- Function to Play the Level Music ---
func play_music_level():
	# This function plays the level music that we loaded earlier.
	# It uses the "_play_music" function to play the music with the default volume (0.0).
	_play_music(level_music)

# --- How to Fix Common Issues ---
# 1. If the music doesn’t play:
#    - Make sure the music file exists at "res://assets/Sfx_Music/inspiring-technology-143299.mp3".
#      In the Godot editor, go to the FileSystem tab (bottom left), and check that the file is in the right folder.
#    - Make sure this script is attached to an AudioStreamPlayer node in the scene.
#      Open the scene (like res://Scenes/MainGame.tscn), find the AudioStreamPlayer node, and check its script in the Inspector.
#    - Make sure something in the game calls "play_music_level()". For example, you might need to call this in MainGame.gd’s "_ready()" function.
# 2. If the music is too loud or too quiet:
#    - Change the "volume" number in "_play_music(level_music)". For example, change it to -10.0 to make it quieter or 5.0 to make it louder.
#    - You can also connect this to the volume sliders in audio_options.gd to let the player control the volume.

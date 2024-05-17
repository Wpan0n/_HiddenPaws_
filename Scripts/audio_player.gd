extends AudioStreamPlayer

# Preload the level music audio file.
const level_music = preload("res://assets/Sfx_Music/inspiring-technology-143299.mp3")

# Function to play music with specified volume.
func _play_music(music: AudioStream, volume = 0.0):
	# If the provided music stream is already playing, return without doing anything.
	if stream == music:
		return
	
	# Set the music stream and volume.
	stream = music
	volume_db = volume
	
	# Start playing the music.
	play()

# Function to play the level music with default volume.
func play_music_level():
	# Call the _play_music function with the preloaded level music and default volume.
	_play_music(level_music)

extends Label

# --- What This Script Does ---
# This script controls a stopwatch in the game. It shows how much time has passed
# since the game started, in the format "MM:SS:MMM" (minutes, seconds, milliseconds).
# It’s attached to a Label node (a piece of text on the screen) and updates the text
# to show the current time.

# --- Time Variable ---
# This keeps track of how much time has passed (in seconds).
var time_elapsed = 0.0  # Starts at 0 seconds.

# --- How This Works When the Game Starts ---
func _ready():
	# This runs when the game starts.
	# It updates the timer display to show the starting time (usually 00:00:000).
	update_timer_display()

# --- Set the Time ---
func set_time_elapsed(time: float):
	# This function lets another script (like GameUI.gd) set the current time.
	# For example, GameUI.gd uses this to set the time when the game loads or resets.
	
	# Set the new time (in seconds).
	time_elapsed = time
	# Update the timer display to show the new time.
	update_timer_display()

# --- Update the Timer Display ---
func update_timer_display():
	# This updates the text on the screen to show the current time in "MM:SS:MMM" format.
	
	# Calculate minutes by dividing the total seconds by 60.
	# For example, if time_elapsed is 125.5 seconds, this is 2 minutes (125.5 / 60 = 2).
	var minutes = int(time_elapsed / 60)
	
	# Calculate seconds by getting the remainder after dividing by 60.
	# For example, 125.5 seconds is 2 minutes and 5 seconds (125.5 % 60 = 5).
	var seconds = int(time_elapsed) % 60
	
	# Calculate milliseconds by taking the decimal part of the time and multiplying by 1000.
	# For example, if time_elapsed is 125.456 seconds, this is 456 milliseconds.
	var milliseconds = int((time_elapsed - int(time_elapsed)) * 1000)
	
	# Update the text to show the time in the format "MM:SS:MMM".
	# "%02d" means "show the number with at least 2 digits, add a 0 if needed" (e.g., 05).
	# "%03d" means "show the number with at least 3 digits, add 0s if needed" (e.g., 005).
	# So if minutes=2, seconds=5, milliseconds=456, this shows "02:05:456".
	text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

# --- How to Fix Common Issues ---
# 1. If the timer doesn’t show up on the screen:
#    - Make sure this script is attached to a Label node in the scene.
#      Open the scene (likely res://Scenes/MainGame.tscn), find the Stopwatch node under GameUI > Score, and check its script in the Inspector.
#    - Make sure the Label node is visible.
#      In the editor, select the Stopwatch node, and in the Inspector, make sure "Visible" is checked.
# 2. If the timer doesn’t update:
#    - Make sure GameUI.gd is calling "set_time_elapsed()" to update the time.
#      Check GameUI.gd’s "_process()" function—it should call "stopwatch.set_time_elapsed(time_elapsed)".
#    - Make sure the GameUI node can find this stopwatch.
#      In GameUI.gd, the path to the stopwatch is "$Score/Stopwatch". Make sure the node names match in the scene.
# 3. If the timer format looks wrong (e.g., "2:5:456" instead of "02:05:456"):
#    - The format string "%02d:%02d:%03d" makes sure there are leading zeros.
#    - If it’s still wrong, let me know, and we can adjust the format.

extends Camera2D

# --- What This Script Does ---
# This script controls the game camera. It lets the player zoom in and out with the mouse wheel
# and move (pan) the camera by clicking and dragging with the left mouse button.
# It makes the camera move and zoom smoothly to avoid jumpiness.

# --- Camera Settings ---
# These numbers control where the camera is looking and how zoomed in it is.
var _target_zoom: float = 0.25  # The zoom level we want to reach (0.25 means zoomed out a lot).
var _target_position: Vector2 = Vector2.ZERO  # The position (x, y) we want the camera to move to.

# --- Zoom and Movement Rules ---
# These numbers set the limits and speed for zooming and moving.
const MIN_ZOOM: float = 0.24  # The smallest zoom level (can’t zoom out more than this).
const MAX_ZOOM: float = 1.5   # The biggest zoom level (can’t zoom in more than this).
const ZOOM_INCREMENT: float = 0.025  # How much the zoom changes when you scroll the mouse wheel.
const ZOOM_RATE: float = 8.0  # How fast the zoom changes (higher = faster, lower = smoother).
const DRAG_SPEED: float = 1.0  # How fast the camera moves when you drag it with the mouse.
const MOVE_SMOOTHING: float = 12.0  # How smooth the camera movement is (higher = smoother).
const DRAG_DAMPING: float = 0.9  # Slows down the dragging to make it less shaky.

# --- Dragging State ---
# These keep track of whether the player is dragging the camera and how fast it’s moving.
var dragging: bool = false  # True when the player is holding the left mouse button to drag.
var drag_start: Vector2 = Vector2.ZERO  # Where the mouse was when the player started dragging.
var drag_velocity: Vector2 = Vector2.ZERO  # How fast the camera is moving while dragging.

# --- How This Works When the Game Starts ---
func _ready():
	# This runs when the game starts.
	
	# Set the camera’s starting position (x=100, y=200 on the screen).
	_target_position = Vector2(100, 200)
	position = _target_position  # Move the camera to this position right away.
	
	# Set the starting zoom level (zoomed out to 0.25).
	zoom = Vector2(_target_zoom, _target_zoom)
	# Make sure the zoom isn’t too big or too small.
	_enforce_camera_limits()

# --- Handle Mouse Actions (Zooming and Dragging) ---
func _unhandled_input(event: InputEvent) -> void:
	# This checks what the player does with the mouse (like scrolling or clicking).
	
	# If the player uses the mouse wheel or clicks...
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				# Scroll up = zoom in.
				zoom_in()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				# Scroll down = zoom out.
				zoom_out()
			elif event.button_index == MOUSE_BUTTON_LEFT:
				# Left click = start dragging the camera.
				dragging = true
				drag_start = event.position  # Remember where the mouse was.
				drag_velocity = Vector2.ZERO  # Reset the movement speed.
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				# Stop dragging when the player releases the left mouse button.
				dragging = false

	# If the player is dragging the mouse (holding left click and moving)...
	if event is InputEventMouseMotion and dragging:
		# Calculate how far the mouse moved and move the camera that much.
		# "event.relative" is how far the mouse moved since the last frame.
		# We adjust the movement based on the zoom level and drag speed.
		var drag_delta = event.relative * DRAG_SPEED / zoom  # Normalize by zoom level.
		drag_velocity = drag_delta * DRAG_DAMPING  # Slow down the movement to reduce shakiness.
		_target_position -= drag_velocity  # Move the camera in the opposite direction of the drag.

# --- Update the Camera Every Frame ---
func _process(delta: float) -> void:
	# This runs every frame (like 60 times a second).
	# "delta" is the time since the last frame (in seconds).
	
	# Smoothly change the zoom to the target zoom level.
	# "lerp" makes the change gradual, and "ZOOM_RATE" controls how fast it happens.
	var new_zoom = zoom.lerp(Vector2(_target_zoom, _target_zoom), 1.0 - exp(-ZOOM_RATE * delta))
	# Make sure the zoom stays between the minimum and maximum limits.
	zoom = new_zoom.clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
	
	# Smoothly move the camera to the target position.
	# "lerp" makes the movement gradual, and "MOVE_SMOOTHING" controls how smooth it is.
	position = position.lerp(_target_position, 1.0 - exp(-MOVE_SMOOTHING * delta))
	
	# Optional: If you want to stop the camera from moving too far, you can use this.
	# It’s commented out right now (starts with #).
	# _enforce_position_limits()

# --- Zoom In Function ---
func zoom_in() -> void:
	# This makes the camera zoom in (get closer) by a small amount.
	# It increases the target zoom but won’t go past the maximum zoom limit.
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	# Make sure the zoom isn’t too big.
	_enforce_camera_limits()

# --- Zoom Out Function ---
func zoom_out() -> void:
	# This makes the camera zoom out (get farther) by a small amount.
	# It decreases the target zoom but won’t go below the minimum zoom limit.
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	# Make sure the zoom isn’t too small.
	_enforce_camera_limits()

# --- Keep Zoom Within Limits ---
func _enforce_camera_limits():
	# This makes sure the zoom level stays between MIN_ZOOM and MAX_ZOOM.
	# "clamp" keeps the number in a specific range.
	_target_zoom = clamp(_target_zoom, MIN_ZOOM, MAX_ZOOM)

# --- Optional: Limit Camera Movement ---
# This function is commented out (starts with #) but can be used to stop the camera from moving too far.
func _enforce_position_limits():
	# Example: Limit panning to a specific area.
	# This calculates how far the camera can move based on the screen size and zoom level.
	var viewport_size = get_viewport_rect().size / zoom
	var min_pos = Vector2(-viewport_size.x, -viewport_size.y)
	var max_pos = Vector2(viewport_size.x, viewport_size.y)
	# Keep the camera position within these limits.
	_target_position = _target_position.clamp(min_pos, max_pos)

# --- How to Fix Common Issues ---
# 1. If the camera feels shaky when zooming or panning:
#    - Try lowering ZOOM_RATE (e.g., change it to 6.0) to make zooming smoother.
#    - Try lowering MOVE_SMOOTHING (e.g., change it to 8.0) to make panning smoother.
#    - Open the Godot editor, go to Debug > Profiler, and click Start Profiling while moving the camera.
#      If you see "_process" taking a long time (like more than 5ms), let me know, and we can make it faster.
# 2. If the camera doesn’t zoom or pan at all:
#    - Make sure this script is attached to the Camera2D node in your scene.
#      Open the scene (like res://Scenes/MainGame.tscn), right-click the Camera2D node, and check its script in the Inspector.
#    - Make sure the Camera2D is set as the current camera.
#      In the editor, select the Camera2D node, and in the Inspector, enable the "Current" checkbox.
# 3. If zooming or panning feels too fast or too slow:
#    - Change ZOOM_INCREMENT (e.g., to 0.01 for smaller steps or 0.05 for bigger steps).
#    - Change ZOOM_RATE (e.g., to 4.0 for slower zooming or 10.0 for faster zooming).
#    - Change DRAG_SPEED (e.g., to 0.5 for slower dragging or 2.0 for faster dragging).

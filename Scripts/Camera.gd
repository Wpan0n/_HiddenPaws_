extends Camera2D

# --- What This Script Does ---
# This script controls the game camera. It lets the player zoom in/out with the mouse wheel
# towards the cursor position and pan by clicking and dragging with the left mouse button.
# It ensures smooth zooming and panning.

# --- Camera Settings ---
var _target_zoom: float = 1.0  # Increased initial zoom for testing.
var _target_position: Vector2 = Vector2.ZERO  # The position we want the camera to move to.

# --- Zoom and Movement Rules ---
const MIN_ZOOM: float = 0.24  # Smallest zoom level.
const MAX_ZOOM: float = 1.5   # Biggest zoom level.
const ZOOM_INCREMENT: float = 0.05  # Slightly larger for noticeable steps.
const ZOOM_RATE: float = 10.0  # Adjusted for smoother transitions.
const DRAG_SPEED: float = 1.0  # Speed of camera dragging.
const MOVE_SMOOTHING: float = 10.0  # Smoothness of camera movement.
const DRAG_DAMPING: float = 0.9  # Damping for drag movement.

# --- Dragging State ---
var dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var drag_velocity: Vector2 = Vector2.ZERO

# --- How This Works When the Game Starts ---
func _ready():
	_target_position = Vector2(100, 200)
	position = _target_position
	zoom = Vector2(_target_zoom, _target_zoom)
	_enforce_camera_limits()
	print("Camera initialized: position=", position, " zoom=", zoom)

# --- Handle Mouse Actions (Zooming and Dragging) ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				# Zoom in towards the cursor.
				var mouse_pos = get_viewport().get_mouse_position()
				print("Zoom in at viewport_mouse_pos=", mouse_pos)
				zoom_in(mouse_pos)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				# Zoom out from the cursor.
				var mouse_pos = get_viewport().get_mouse_position()
				print("Zoom out at viewport_mouse_pos=", mouse_pos)
				zoom_out(mouse_pos)
			elif event.button_index == MOUSE_BUTTON_LEFT:
				dragging = true
				drag_start = event.position
				drag_velocity = Vector2.ZERO
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = false

	if event is InputEventMouseMotion and dragging:
		var drag_delta = event.relative * DRAG_SPEED / zoom
		drag_velocity = drag_delta * DRAG_DAMPING
		_target_position -= drag_velocity

# --- Update the Camera Every Frame ---
func _process(delta: float) -> void:
	# Smoothly adjust zoom.
	var new_zoom = zoom.lerp(Vector2(_target_zoom, _target_zoom), 1.0 - exp(-ZOOM_RATE * delta))
	zoom = new_zoom.clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
	
	# Smoothly adjust position.
	position = position.lerp(_target_position, 1.0 - exp(-MOVE_SMOOTHING * delta))

# --- Zoom In Function ---
func zoom_in(viewport_mouse_pos: Vector2) -> void:
	# Get viewport center and calculate offset in world space.
	var viewport_center = get_viewport_rect().size / 2.0
	var offset = (viewport_mouse_pos - viewport_center) / zoom
	print("Zoom in: offset=", offset, " current zoom=", zoom)
	
	# Increase zoom level.
	var prev_zoom = _target_zoom
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	_enforce_camera_limits()
	
	# Adjust position to zoom towards the cursor.
	var new_offset = (viewport_mouse_pos - viewport_center) / zoom
	_target_position += (offset - new_offset) * zoom
	print("Zoom in: new target_position=", _target_position, " new target_zoom=", _target_zoom)

# --- Zoom Out Function ---
func zoom_out(viewport_mouse_pos: Vector2) -> void:
	# Get viewport center and calculate offset in world space.
	var viewport_center = get_viewport_rect().size / 2.0
	var offset = (viewport_mouse_pos - viewport_center) / zoom
	print("Zoom out: offset=", offset, " current zoom=", zoom)
	
	# Decrease zoom level.
	var prev_zoom = _target_zoom
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	_enforce_camera_limits()
	
	# Adjust position to zoom away from the cursor.
	var new_offset = (viewport_mouse_pos - viewport_center) / zoom
	_target_position += (offset - new_offset) * zoom
	print("Zoom out: new target_position=", _target_position, " new target_zoom=", _target_zoom)

# --- Keep Zoom Within Limits ---
func _enforce_camera_limits():
	_target_zoom = clamp(_target_zoom, MIN_ZOOM, MAX_ZOOM)

# --- Optional: Limit Camera Movement ---
# func _enforce_position_limits():
# 	var viewport_size = get_viewport_rect().size / zoom
# 	var min_pos = Vector2(-viewport_size.x, -viewport_size.y)
# 	var max_pos = Vector2(viewport_size.x, viewport_size.y)
# 	_target_position = _target_position.clamp(min_pos, max_pos)

# --- How to Fix Common Issues ---
# 1. If the camera doesn’t zoom towards the cursor:
#    - Check the Godot Output tab for viewport_mouse_pos and target_position values.
#    - Ensure the Camera2D node is set as "Current" in the Inspector.
#    - Verify no CanvasLayer is affecting mouse coordinates (check MainGame.tscn).
# 2. If zooming feels shaky:
#    - Lower ZOOM_RATE or MOVE_SMOOTHING to 8.0.
#    - Use the Godot Profiler (Debug > Profiler) to check _process performance.
# 3. If no zooming occurs:
#    - Ensure the script is attached to the Camera2D node in res://Scenes/MainGame.tscn.
#    - Check for errors in the Godot Output tab.
# 4. If zooming is too fast/slow:
#    - Adjust ZOOM_INCREMENT (e.g., 0.1 for larger steps) or ZOOM_RATE (e.g., 5.0 for slower).

extends Camera2D

# Target zoom level
var _target_zoom: float = 0.25
var _target_position: Vector2 = Vector2.ZERO

# Constants for zoom limits and increment
const MIN_ZOOM: float = 0.24
const MAX_ZOOM: float = 1.5
const ZOOM_INCREMENT: float = 0.025
const ZOOM_RATE: float = 8.0  # Adjusted for smoother zooming
const DRAG_SPEED: float = 1.0  # Reduced for smoother dragging
const MOVE_SMOOTHING: float = 12.0  # Adjusted for smoother panning
const DRAG_DAMPING: float = 0.9  # Dampens drag movement to reduce jitter

# Variables for click-and-drag functionality
var dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var drag_velocity: Vector2 = Vector2.ZERO

func _ready():
	# Set initial position and zoom
	_target_position = Vector2(100, 200)
	position = _target_position
	zoom = Vector2(_target_zoom, _target_zoom)
	_enforce_camera_limits()

func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse wheel for zooming
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_out()
			elif event.button_index == MOUSE_BUTTON_LEFT:
				dragging = true
				drag_start = event.position
				drag_velocity = Vector2.ZERO  # Reset velocity on new drag
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = false

	# Handle mouse drag for panning
	if event is InputEventMouseMotion and dragging:
		var drag_delta = event.relative * DRAG_SPEED / zoom  # Normalize by zoom level
		drag_velocity = drag_delta * DRAG_DAMPING  # Apply damping
		_target_position -= drag_velocity

func _process(delta: float) -> void:
	# Smoothly interpolate zoom
	var new_zoom = zoom.lerp(Vector2(_target_zoom, _target_zoom), 1.0 - exp(-ZOOM_RATE * delta))
	zoom = new_zoom.clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
	
	# Smoothly interpolate position
	position = position.lerp(_target_position, 1.0 - exp(-MOVE_SMOOTHING * delta))
	
	# Optional: Enforce position limits if needed (e.g., to prevent panning too far)
	# _enforce_position_limits()

func zoom_in() -> void:
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	_enforce_camera_limits()

func zoom_out() -> void:
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	_enforce_camera_limits()

func _enforce_camera_limits():
	_target_zoom = clamp(_target_zoom, MIN_ZOOM, MAX_ZOOM)

# Optional: Add position limits if needed
func _enforce_position_limits():
	# Example: Limit panning to a specific area
	var viewport_size = get_viewport_rect().size / zoom
	var min_pos = Vector2(-viewport_size.x, -viewport_size.y)
	var max_pos = Vector2(viewport_size.x, viewport_size.y)
	_target_position = _target_position.clamp(min_pos, max_pos)

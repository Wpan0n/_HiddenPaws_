extends Camera2D

# --- Purpose ---
# Controls the game camera with smooth zooming towards the cursor (mouse wheel)
# and panning by dragging (left mouse button).

# --- Settings ---
var _target_zoom: float = 1.0  # Initial zoom level.
var _target_position: Vector2 = Vector2.ZERO  # Target position for smooth movement.

# --- Constants ---
const MIN_ZOOM: float = 0.24
const MAX_ZOOM: float = 1.5
const ZOOM_INCREMENT: float = 0.05
const ZOOM_RATE: float = 10.0  # Smooth zoom transition.
const DRAG_SPEED: float = 2.0  # Increased for better dragging response.
const MOVE_SMOOTHING: float = 12.0  # Smoother movement.
const DRAG_DAMPING: float = 0.9  # Damping factor for drag.

# --- Dragging State ---
var dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var drag_velocity: Vector2 = Vector2.ZERO

# --- Initialization ---
func _ready() -> void:
	_target_position = Vector2(100, 200)
	position = _target_position
	zoom = Vector2(_target_zoom, _target_zoom)
	_enforce_camera_limits()
	print("Camera initialized: position=%s, zoom=%s" % [position, zoom])

# --- Handle Input ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_echo():
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var mouse_pos = get_viewport().get_mouse_position()
				print("Zoom in at viewport_mouse_pos=%s" % mouse_pos)
				zoom_in(mouse_pos)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var mouse_pos = get_viewport().get_mouse_position()
				print("Zoom out at viewport_mouse_pos=%s" % mouse_pos)
				zoom_out(mouse_pos)
			elif event.button_index == MOUSE_BUTTON_LEFT:
				dragging = true
				drag_start = event.position
				drag_velocity = Vector2.ZERO
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		var drag_delta = event.relative * DRAG_SPEED / zoom.x
		drag_velocity = (drag_delta + drag_velocity * DRAG_DAMPING) * 0.5  # Blend current and damped velocity.
		_target_position -= drag_velocity
		# print("Dragging: target_position=%s, drag_velocity=%s" % [_target_position, drag_velocity])

# --- Update Every Frame ---
func _process(delta: float) -> void:
	var new_zoom = zoom.lerp(Vector2(_target_zoom, _target_zoom), 1.0 - exp(-ZOOM_RATE * delta))
	zoom = new_zoom.clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
	position = position.lerp(_target_position, 1.0 - exp(-MOVE_SMOOTHING * delta))

# --- Zoom In ---
func zoom_in(viewport_mouse_pos: Vector2) -> void:
	var viewport_center = get_viewport_rect().size / 2.0
	var local_offset = (viewport_mouse_pos - viewport_center) / zoom
	print("Zoom in: local_offset=%s, current_zoom=%s" % [local_offset, zoom])
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	_enforce_camera_limits()
	var new_local_offset = (viewport_mouse_pos - viewport_center) / zoom
	_target_position += (local_offset - new_local_offset) * zoom
	print("Zoom in: target_position=%s, target_zoom=%s" % [_target_position, _target_zoom])

# --- Zoom Out ---
func zoom_out(viewport_mouse_pos: Vector2) -> void:
	var viewport_center = get_viewport_rect().size / 2.0
	var local_offset = (viewport_mouse_pos - viewport_center) / zoom
	print("Zoom out: local_offset=%s, current_zoom=%s" % [local_offset, zoom])
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	_enforce_camera_limits()
	var new_local_offset = (viewport_mouse_pos - viewport_center) / zoom
	_target_position += (local_offset - new_local_offset) * zoom
	print("Zoom out: target_position=%s, target_zoom=%s" % [_target_position, _target_zoom])

# --- Enforce Zoom Limits ---
func _enforce_camera_limits() -> void:
	_target_zoom = clamp(_target_zoom, MIN_ZOOM, MAX_ZOOM)

# --- Troubleshooting ---
# - Choppy dragging: Increase DRAG_SPEED (e.g., 3.0) or MOVE_SMOOTHING (e.g., 15.0), check Profiler.
# - Zoom not centering: Verify Camera2D "Current", check Output for viewport_mouse_pos.
# - No response: Ensure script attached, no CanvasLayer interference.

extends Camera2D

# Target zoom level
var _target_zoom: float = 1.0

# Constants for zoom limits and increment
const MIN_ZOOM: float = 0.24
const MAX_ZOOM: float = 1
const ZOOM_INCREMENT: float = 0.025
const ZOOM_RATE: float = 2.0
const DRAG_SPEED: float = 3  # New constant to control drag speed
const ZOOM_SPEED: float = 2.0  # New constant to control zoom speed

# Variables for click-and-drag functionality
var dragging: bool = false
var drag_start: Vector2

# This function handles input events that are not handled by other nodes
func _unhandled_input(event: InputEvent) -> void:
	# Handle middle mouse button drag for panning
	if event is InputEventMouseMotion:
		if dragging:
			position -= event.relative * zoom * DRAG_SPEED  # Apply drag speed multiplier

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
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = false

# Function to zoom in
func zoom_in() -> void:
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT * ZOOM_SPEED, MAX_ZOOM)
	set_physics_process(true)

# Function to zoom out
func zoom_out() -> void:
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT * ZOOM_SPEED, MIN_ZOOM)
	set_physics_process(true)

# Called every physics frame to update the zoom level smoothly
func _physics_process(delta: float) -> void:
	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	set_physics_process(not is_equal_approx(zoom.x, _target_zoom))

# Function to enforce camera limits
func _enforce_camera_limits():
	if _target_zoom < MIN_ZOOM:
		_target_zoom = MIN_ZOOM
	elif _target_zoom > MAX_ZOOM:
		_target_zoom = MAX_ZOOM

# Ensure the zoom level respects the camera limits on ready
func _ready():
	_enforce_camera_limits()
	# Set the camera position to a new Vector2 (x, y)
	position = Vector2(100, 200)  # Change the values to the desired coordinates

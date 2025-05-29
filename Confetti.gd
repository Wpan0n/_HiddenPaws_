extends Node2D

# --- Purpose ---
# Controls a confetti particle effect that plays when a cat sprite is clicked.
# Scales particles based on camera zoom and removes itself after the effect finishes.

# --- Node References ---
@onready var particles: CPUParticles2D = $ConfettiParticles
@onready var lifetime_timer: Timer = $LifetimeTimer

# --- Constants ---
const MAX_SCALE_FACTOR: float = 2.0  # Cap to prevent particles from getting too large.

# --- Initialization ---
func _ready() -> void:
	if not particles or not lifetime_timer:
		print("Error: ConfettiParticles or LifetimeTimer not found in %s" % name)
		queue_free()
		return
	
	# Adjust particle scale based on camera zoom for consistent screen-space size.
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera:
		var zoom_level: float = camera.zoom.x
		# Use MAX_ZOOM (1.5) as the reference for base scale.
		var reference_zoom: float = 2
		var scale_factor: float = reference_zoom / zoom_level
		# Cap the scale factor to avoid excessive growth at low zoom.
		scale_factor = min(scale_factor, MAX_SCALE_FACTOR)
		particles.scale_amount_min *= scale_factor
		particles.scale_amount_max *= scale_factor
		print("Confetti scale adjusted: min=%s, max=%s, zoom=%s, scale_factor=%s" % [particles.scale_amount_min, particles.scale_amount_max, zoom_level, scale_factor])
	else:
		print("Warning: No active Camera2D found")
	
	# Start emission and timer.
	if not particles.emitting:
		particles.emitting = true
		print("Confetti emitting at %s" % global_position)
	
	lifetime_timer.start()
	if not lifetime_timer.is_connected("timeout", _on_lifetime_timer_timeout):
		lifetime_timer.connect("timeout", _on_lifetime_timer_timeout)
		print("LifetimeTimer connected")

# --- Cleanup ---
func _on_lifetime_timer_timeout() -> void:
	# print("Confetti lifetime expired, removing")
	queue_free()

# --- Troubleshooting ---
# - Small particles at zoom out: Increase base Scale Amount (e.g., Min: 15.0, Max: 30.0).
# - Too large at zoom in: Lower MAX_SCALE_FACTOR (e.g., 1.5).
# - No particles: Check Output, verify Emitting/Amount, node names.

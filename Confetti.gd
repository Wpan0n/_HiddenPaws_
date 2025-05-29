extends Node2D

# --- What This Script Does ---
# This script controls a confetti particle effect that plays when a cat sprite is clicked.
# It emits particles and removes itself after the effect finishes.

# --- Node References ---
@onready var particles: CPUParticles2D = $ConfettiParticles
@onready var lifetime_timer: Timer = $LifetimeTimer

# --- How This Works When the Scene Starts ---
func _ready():
	# Start the particles and timer.
	particles.emitting = true
	lifetime_timer.start()

# --- When the Timer Finishes ---
func _on_lifetime_timer_timeout():
	# Remove the confetti effect from the scene.
	queue_free()

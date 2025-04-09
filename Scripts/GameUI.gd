extends Control

var score = 0  # Tracks number of cats clicked
var max_score = 100
var time_elapsed = 0.0  # Tracks elapsed time in seconds
var is_game_running = false
var clicked_cats = []  # Tracks which cats were clicked

@onready var scoreLabel = $Score
@onready var score_sound_player = $"../../ScoreSoundPlayer"
@onready var colorRect = $"../../Fireworks"
@onready var hooray_sfx = $"../../Hooray_EndGame"
@onready var stopwatch = $Score/Stopwatch

func _ready():
	print("GameUI ready called")
	if not is_inside_tree():
		print("Error: Node is not in the scene tree!")
	
	# Load saved game data
	score = SaveGame.get_high_score()
	time_elapsed = SaveGame.get_best_time()
	clicked_cats = SaveGame.get_clicked_cats()
	
	if stopwatch and stopwatch.has_method("set_time_elapsed"):
		stopwatch.set_time_elapsed(time_elapsed)
	update_score_label()
	
	for child in get_tree().get_nodes_in_group("sprite_group"):
		if child is Sprite2D:
			child.sprite_color_changed.connect(_on_sprite_color_changed.bind(child))
			if child.name in clicked_cats:
				child.modulate = Color.GRAY
	if stopwatch:
		stopwatch.current_score = score
	else:
		print("Error: Stopwatch node not found.")
	is_game_running = true

func _process(delta: float) -> void:
	if is_game_running:
		time_elapsed += delta
		if stopwatch and stopwatch.has_method("update_timer_display"):
			stopwatch.set_time_elapsed(time_elapsed)
			update_stopwatch_display()

func _on_sprite_color_changed(sprite: Sprite2D):
	print("Color change detected on: ", sprite.name)
	if not sprite.name in clicked_cats:
		score += 1
		clicked_cats.append(sprite.name)
		sprite.modulate = Color.GRAY
	print("Score: ", score)
	update_score_label()
	if stopwatch:
		stopwatch.current_score = score
	else:
		print("Error: Stopwatch node not found.")

	if score >= max_score:
		print("Playing score sound")
		play_score_sound()
		if stopwatch:
			stopwatch.stop_timer()
		else:
			print("Error: Stopwatch node not found.")

	if score == max_score:
		colorRect.visible = true
		call_deferred("turn_off_color_rect_after_delay")
	else:
		colorRect.visible = false

func update_score_label():
	if scoreLabel:
		scoreLabel.text = "%d/%d" % [score, max_score]

func update_stopwatch_display():
	if stopwatch:
		var minutes = int(time_elapsed / 60)
		var seconds = int(time_elapsed) % 60
		var milliseconds = int((time_elapsed - int(time_elapsed)) * 1000)
		stopwatch.text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

func play_score_sound():
	if score_sound_player:
		print("Score sound player exists")
		score_sound_player.play()
		if score_sound_player.is_playing():
			play_hooray_sfx()
	else:
		print("Score sound player does not exist")

func turn_off_color_rect_after_delay():
	var elapsed = 0.0
	while elapsed < 15:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	colorRect.visible = false

func play_hooray_sfx():
	if hooray_sfx:
		print("Playing hooray sound effect")
		hooray_sfx.play()
	else:
		print("Hooray sound effect not available")

func save_and_exit():
	is_game_running = false
	SaveGame.save_game(time_elapsed, score, clicked_cats)

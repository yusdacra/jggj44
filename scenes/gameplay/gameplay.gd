extends Node
class_name Gameplay

@export var intensity_music_layers: Dictionary = {
	0.0: "dark_three",
	25.0: "dark_two",
	50.0: "dark_one",
	75.0: "neutral",
	100.0: "neutral",
	125.0: "light_one",
	150.0: "light_two",
	175.0: "light_three",
}
@export var time_music_layers: Dictionary = {
	0.0: "day",
	180.0: "night",
}

var tp_points: Dictionary = {}
var sp_lights: Dictionary = {}

func post_ready(params: Dictionary):
	for map: Node3D in %Maps.get_children(): if not map.visible: map.queue_free()
	AudioServer.set_bus_bypass_effects(AudioServer.get_bus_index("SFX"), true)
	if params.get("fade_music_in", false):
		get_tree().process_frame.connect(_fade_in_music)
	# HACK
	if GameState.time < 180.0: Audio.switch_to_clip("daytime")
	if GameState.time < 180.0:
		%Sun.light_energy = 1.0
		%WorldEnvironment.environment.sky.sky_material = preload("res://resources/environments/day_sky.tres")
		%Stars.visible = false
	else:
		%Sun.light_energy = 0.15
		%WorldEnvironment.environment.sky.sky_material = preload("res://resources/environments/night_sky.tres")
		%Stars.speed_scale = 10.0
		get_tree().create_timer(3.0).timeout.connect(func(): %Stars.speed_scale = 1.0)
		%Stars.visible = true


func pre_start(params: Dictionary):
	if not Audio.bgm.playing: Audio.bgm.play()
	GameState.player.controller.jumping_enabled = false
	GameState.player.controller.sprint_enabled = false
	GameState.player.controller.crouch_enabled = false
	if params.get("left_nightmare", false):
		GameState.player.controller.global_position = %NightmareLeaveSpawn.global_position
		GameState.player.controller.HEAD.rotation = %NightmareLeaveSpawn.global_rotation


func start(params):
	pass
	#update_bgm_layer()
	#GameState.time_changed.connect(func(x): update_bgm_layer())
	#GameState.light_intensity_changed.connect(func(x): update_bgm_layer())

func _fade_in_music():
	var delta := get_process_delta_time()
	Audio.bgm.volume_db = linear_to_db(move_toward(db_to_linear(Audio.bgm.volume_db), 1.0, delta * absf(1.0 - db_to_linear(Audio.bgm.volume_db))))
	if is_zero_approx(db_to_linear(Audio.bgm.volume_db)):
		get_tree().process_frame.disconnect(_fade_in_music)

func update_bgm_layer():
	var intensity_layer_levels = intensity_music_layers.keys()
	intensity_layer_levels.sort()
	var intensity_layer_suffix: String = intensity_music_layers[intensity_layer_levels[0]]
	for level: float in intensity_layer_levels:
		if GameState.light_intensity >= level:
			intensity_layer_suffix = intensity_music_layers[level]
			continue
		else:
			break
	var time_layer_levels = time_music_layers.keys()
	time_layer_levels.sort()
	var time_layer_prefix: String = time_music_layers[time_layer_levels[0]]
	for level: float in time_layer_levels:
		if GameState.time >= level:
			time_layer_prefix = time_music_layers[level]
			continue
		else:
			break
	Audio.transition_to("%s_%s" % [time_layer_prefix, intensity_layer_suffix])

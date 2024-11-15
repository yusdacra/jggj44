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


func pre_start(params: Dictionary):
	if params.get("left_nightmare", false):
		GameState.player.controller.global_position = %NightmareLeaveSpawn.global_position
		GameState.player.controller.HEAD.rotation = %NightmareLeaveSpawn.global_rotation

func start(params):
	update_bgm_layer()
	GameState.time_changed.connect(func(x): update_bgm_layer())
	GameState.light_intensity_changed.connect(func(x): update_bgm_layer())


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
	BGM.transition_to("%s_%s" % [time_layer_prefix, intensity_layer_suffix])

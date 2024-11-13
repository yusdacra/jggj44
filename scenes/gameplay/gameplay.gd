extends Node
class_name Gameplay

@export var player: Player
@export var ui_layer: UiLayer

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

var time: float = 0.0:
	set(new_time):
		time = fmod(new_time, 360.0) # rolls over after night
		Loggie.info("time changed to %s" % time)
		update_bgm_layer()
var light_intensity: float = 100.0: # start at 100, between 0 and 200
	set(new_intensity):
		light_intensity = new_intensity
		Loggie.info("light intensity changed to %s" % light_intensity)
		update_bgm_layer()

# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(params):
	var cur_scene: Node = get_tree().current_scene
	Loggie.info("Scene pre start: %s (%s)" % [cur_scene.name, cur_scene.scene_file_path])
	for map: Node3D in %Maps.get_children():
		if not map.visible: map.queue_free()


# `start()` is called after pre_start and after the graphic transition ends.
func start():
	update_bgm_layer()


func update_bgm_layer():
	var intensity_layer_levels = intensity_music_layers.keys()
	intensity_layer_levels.sort()
	var intensity_layer_suffix: String = intensity_music_layers[intensity_layer_levels[0]]
	for level: float in intensity_layer_levels:
		if light_intensity >= level:
			intensity_layer_suffix = intensity_music_layers[level]
			continue
		else:
			break
	var time_layer_levels = time_music_layers.keys()
	time_layer_levels.sort()
	var time_layer_prefix: String = time_music_layers[time_layer_levels[0]]
	for level: float in time_layer_levels:
		if time >= level:
			time_layer_prefix = time_music_layers[level]
			continue
		else:
			break
	BGM.transition_to("%s_%s" % [time_layer_prefix, intensity_layer_suffix])

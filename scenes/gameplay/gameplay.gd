extends Node
class_name Gameplay

@export var player: Player
@export var ui_layer: UiLayer

var light_intensity: float = 100.0: # start at 100, between 0 and 200
	set(new_intensity):
		light_intensity = new_intensity

# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(params):
	var cur_scene: Node = get_tree().current_scene
	print("Scene loaded: ", cur_scene.name, " (", cur_scene.scene_file_path, ")")
	if params:
		for key in params:
			var val = params[key]
			printt("", key, val)


# `start()` is called after pre_start and after the graphic transition ends.
func start():
	pass

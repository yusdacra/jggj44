# Scenes manager.
# When the loading of a new scene is completed, it calls
# two methods on the new loaded scene (if they are defined):
# 1. `pre_start(params)`: called as soon as the scene is loaded in memory.
#   It passes the `params` object received by
#   `Game.change_scene(new_scene, params)`.
# 2. `start()`: called when the scene transition is finished and when the
#  gameplay input is unlocked
extends Node

signal change_started(scene_path: String, params: Dictionary)
signal change_pre_finish(scene: Node)
signal change_finished(scene: Node)

var _params = {} # params caching
var _loading_start_time = 0

@onready var transitions = get_node("/root/Transitions")
@onready var _history = preload("res://addons/ggt-core/scenes/scenes-history.gd").new()
@onready var _loader_mt = preload("res://addons/ggt-core/utils/resource_multithread_loader.gd").new()
var config = preload("res://addons/ggt-core/config.tres")

var current: Node = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if transitions:
		_loader_mt.resource_stage_loaded.connect(transitions._on_resource_stage_loaded)
	change_started.connect(_on_change_started)
	change_finished.connect(_on_change_finished)
	var cur_scene: Node = get_tree().current_scene
	change_started.emit(cur_scene.scene_file_path, {})
	# if playing a specific scene
	if ProjectSettings.get("application/run/main_scene") != cur_scene.scene_file_path:
		# call pre_start and start method to ensure compatibility with "Play Scene"
		if not cur_scene.is_node_ready():
			await cur_scene.ready
		if cur_scene.has_method("post_ready"):
			cur_scene.post_ready({})
		change_pre_finish.emit(cur_scene)
		if cur_scene.has_method("pre_start"):
			cur_scene.pre_start({})
		if cur_scene.has_method("start"):
			cur_scene.start({})
	change_finished.emit(cur_scene)


func get_last_loaded_scene_data() -> SceneData:
	return _history.get_last_loaded_scene_data()


func _set_new_scene(resource: PackedScene):
	var current_scene = get_tree().current_scene
	current_scene.queue_free()
	await current_scene.tree_exited  # wait for the current scene to be fully removed
	var instanced_scn: Node = resource.instantiate()  # triggers _init
	get_tree().root.add_child(instanced_scn)  # triggers _ready
	if instanced_scn.has_method("post_ready"):
		await instanced_scn.post_ready(_params)
	get_tree().current_scene = instanced_scn
	change_pre_finish.emit(instanced_scn)
	if instanced_scn.has_method("pre_start"):
		await instanced_scn.pre_start(_params)
	if transitions:
		transitions.fade_out()
	if transitions:
		await transitions.anim.animation_finished
	if instanced_scn.has_method("start"):
		instanced_scn.start(_params)
	change_finished.emit(instanced_scn)
	_params = {}
	_loading_start_time = 0


func _transition_appear(params):
	if transitions:
		transitions.fade_in(params)


# Multithread interactive loading
func change_scene_multithread(new_scene: String, params = {}):
	change_started.emit(new_scene, params)
	_params = params
	_loading_start_time = Time.get_ticks_msec()
	_transition_appear(params)
	_loader_mt.resource_loaded.connect(_on_resource_loaded, CONNECT_ONE_SHOT)
	await transitions.transition_covered_screen
	_loader_mt.load_resource(new_scene)


func _on_change_started(new_scene, params):
	_history.add(new_scene, params)

func _on_change_finished(scene: Node):
	current = scene


func _on_resource_loaded(resource):
	if transitions and transitions.is_transition_in_playing():
		await transitions.anim.animation_finished
	var load_time = Time.get_ticks_msec() - _loading_start_time  # ms
	Loggie.info(
		"{scn} loaded in {elapsed}ms".format({"scn": resource.resource_path, "elapsed": load_time})
	)
	# artificially wait some time in order to have a gentle scene transition
	if transitions and load_time < config.transitions_minimum_duration_ms:
		await get_tree().create_timer((config.transitions_minimum_duration_ms - load_time) / 1000.0).timeout
	_set_new_scene(resource)

extends Node3D
class_name Nightmare

var level: Node3D

var player_init_pos: Vector3
var player_init_rot: Vector3

var leave_obj: NightmareLeave
var start_marker: Marker3D
var is_started := false

signal started

func post_ready(params: Dictionary) -> void:
	var level_name: String = params["nightmare"] if params.has("nightmare") else GameState.night_level
	for child: Node3D in %Maps.get_children():
		if child.name == level_name: level = child
		else: child.queue_free()
	AudioServer.set_bus_bypass_effects(AudioServer.get_bus_index("SFX"), false)
	start_marker = level.get_node("Map/entity_nightmare_start")
	leave_obj = level.get_node("Map/entity_nightmare_leave")

func pre_start(params: Dictionary) -> void:
	_for_each_mesh(
		level.get_node("Map"),
		func(mesh: MeshInstance3D): mesh.visible = false,
		func(node: Node): return node.name != leave_obj.name,
	)
	leave_obj.model.visible = false
	GameState.player.controller.immobile = true
	GameState.player.controller.jumping_enabled = true
	GameState.player.controller.sprint_enabled = true
	GameState.player.controller.crouch_enabled = true
	player_init_rot = GameState.player.controller.HEAD.rotation + Vector3(0, PI, 0)
	player_init_pos = GameState.player.controller.global_position
	get_tree().process_frame.connect(check_player_death)

func start(params: Dictionary) -> void:
	level.get_node("Stars").speed_scale = 5.0
	get_tree().create_timer(4.0).timeout.connect(
		func():
			GameState.player.controller.immobile = false
			leave_obj.model.visible = true
			level.get_node("Stars").speed_scale = 1.0
	)
	started.connect(_reveal, CONNECT_ONE_SHOT)

func _reveal():
	_for_each_mesh(
		level.get_node("Map"),
		func(mesh: MeshInstance3D): mesh.visible = true,
		func(node: Node): return node.name != leave_obj.name,
	)

func trigger_start_dialogue():
	UILayer.show_dialogue(preload("res://dialogue/nightmare.dialogue"), "nightmare%s_start" % level.name)
	DialogueManager.dialogue_ended.connect(func(dialogue): is_started = true; started.emit(), CONNECT_ONE_SHOT)

func _force_player_rot():
	var head := GameState.player.controller.HEAD
	var rot_delta := absf(head.rotation.length() - player_init_rot.length())
	var rot_by := get_process_delta_time() * (PI + (rot_delta ** 3.0))
	head.rotation = head.rotation.move_toward(player_init_rot, rot_by)

func check_player_death():
	if GameState.player.controller.global_position.y < %DeathTp.global_position.y:
		GameState.player.controller.global_position = player_init_pos
		VfxLayer.set_chaos(32.0)

func _for_each_mesh(node: Node, f: Callable, filter: Callable = func(node): return true):
	for child in node.get_children():
		if child is Player or not filter.call(child): continue
		if child is MeshInstance3D: f.call(child)
		_for_each_mesh(child, f)

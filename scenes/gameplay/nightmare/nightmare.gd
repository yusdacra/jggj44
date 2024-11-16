extends Node3D

var level: Node3D

var player_init_pos: Vector3
var player_init_rot: Vector3

func post_ready(params: Dictionary) -> void:
	var level_name: String = params["nightmare"] if params.has("nightmare") else GameState.night_level
	for child: Node3D in %Maps.get_children():
		if child.name == level_name: level = child
		else: child.queue_free()
	AudioServer.set_bus_bypass_effects(AudioServer.get_bus_index("SFX"), false)

func pre_start(params: Dictionary) -> void:
	level.get_node("Map").visible = false
	GameState.player.controller.immobile = true
	player_init_rot = GameState.player.controller.HEAD.rotation + Vector3(0, PI, 0)
	player_init_pos = GameState.player.controller.global_position
	get_tree().process_frame.connect(_force_player_rot)
	get_tree().process_frame.connect(check_player_death)

func start(params: Dictionary) -> void:
	level.get_node("Stars").speed_scale = 4.0
	get_tree().create_timer(5.0).timeout.connect(_reveal)

func _reveal():
	get_tree().process_frame.disconnect(_force_player_rot)
	GameState.player.controller.immobile = false
	level.get_node("Map").visible = true
	level.get_node("Stars").speed_scale = 1.0

func _force_player_rot():
	var head := GameState.player.controller.HEAD
	var rot_delta := absf(head.rotation.length() - player_init_rot.length())
	var rot_by := get_process_delta_time() * (PI + (rot_delta ** 3.0))
	head.rotation = head.rotation.move_toward(player_init_rot, rot_by)

func check_player_death():
	if GameState.player.controller.global_position.y < %DeathTp.global_position.y:
		GameState.player.controller.global_position = player_init_pos
		VfxLayer.set_chaos(32.0)

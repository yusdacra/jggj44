extends Interactable
class_name NightmareLeave

@export var func_godot_properties: Dictionary

var scene: Nightmare
var model: Node3D
var orig_pos: Vector3

func _ready() -> void:
	orig_pos = position
	var model: Node3D = load("res://interactable/leave_nightmare/models/%s.tscn" % func_godot_properties["model_name"]).instantiate()
	add_child(model); self.model = model; model.name = "mesh"
	Scenes.change_finished.connect(
		func(scene: Nightmare):
			self.scene = scene
			global_position = scene.start_marker.global_position,
		CONNECT_ONE_SHOT
	)

func _process(delta: float) -> void:
	# breathing
	model.position.y = 0.3 * sin(Time.get_ticks_msec() * 0.001 * 2.0)

func _move_to_leave() -> void:
	var delta := get_process_delta_time()
	position = position.move_toward(orig_pos, delta * (position.distance_to(orig_pos) + 1.0) * 2.0)
	if position.is_equal_approx(orig_pos):
		enabled = true
		get_tree().process_frame.disconnect(_move_to_leave)

func _on_interact(player: Player):
	if scene.is_started:
		player.controller.immobile = true
		Game.change_scene_to_file("res://scenes/gameplay/gameplay.tscn", {"left_nightmare": true})
	else:
		enabled = false
		scene.trigger_start_dialogue()
		scene.started.connect(
			func(): get_tree().process_frame.connect(_move_to_leave),
			CONNECT_ONE_SHOT
		)

func _on_interact_hover(player: Player) -> void:
	if scene.is_started:
		UILayer.show_interact_text("press F to leave")
	else:
		UILayer.show_interact_text("press F to follow")

@tool
extends Node3D
class_name NightmarePlatform

@export var spread := Vector3(0.3, 0.15, 0.3)
@export var speed := 0.1
@export var breathing_spread := 0.1
@export var breathing_speed := 1.0
@export var func_godot_properties: Dictionary:
	set(props):
		func_godot_properties = props
		_update_model()

@onready var dir := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
@onready var breathing_offset := randf_range(-PI, PI)

@onready var start_position: Vector3 = position
@onready var current_position: Vector3 = start_position
@onready var target_position: Vector3 = start_position + spread * dir

func _ready() -> void:
	_update_model()
	if Engine.is_editor_hint(): return
	scale_object_local(Vector3.ONE * randf_range(0.8, 1.3))
	rotation.y = randf_range(0, PI)
	get_tree().process_frame.connect(_animate)

func _update_model() -> void:
	var model_node: Node3D
	var model_name: String = func_godot_properties.get("model_name", "")
	if model_name.is_empty(): model_node = get_children().pick_random()
	else: model_node = get_node(model_name)
	for child in get_children(): child.visible = false
	model_node.visible = true

func _update_random_target() -> void:
	dir = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	target_position = start_position + spread * dir
	get_tree().create_timer(randf_range(5.0, 10.0)).timeout.connect(_update_random_target)

func _animate() -> void:
	var delta := get_process_delta_time()
	current_position = current_position.move_toward(target_position, delta * speed)
	position = current_position
	position.y += breathing_spread * sin(breathing_offset + (Time.get_ticks_msec() as float * 0.001 * breathing_speed))

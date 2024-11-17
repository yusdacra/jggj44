@tool
extends StaticBody3D
class_name NightmarePlatform

const MODELS: Dictionary = {
	"simple": preload("res://assets/models/platform/simple.tres"),
	"triprism": preload("res://assets/models/platform/triprism.fbx"),
}

@export var spread := Vector3(0.3, 0.15, 0.3)
@export var speed := 0.1
@export var breathing_spread := 0.1
@export var breathing_speed := 1.0
@export var func_godot_properties: Dictionary
@export var added_model_name: String

@onready var dir := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
@onready var breathing_offset := randf_range(-PI, PI)

var model: Node3D
var start_position: Vector3
var current_position: Vector3
var target_position: Vector3

func _func_godot_build_complete():
	var model_name: String = MODELS.keys().pick_random()
	_add_model(MODELS[model_name], model_name)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	model = get_node(added_model_name)
	model.scale_object_local(Vector3.ONE * randf_range(0.8, 1.3))
	model.rotation.y = randf_range(0, PI)
	start_position = model.position
	current_position = start_position
	target_position = start_position + spread * dir
	get_tree().process_frame.connect(_animate)
	_update_random_target()

func _add_model(model, model_name: String) -> void:
	var model_node: Node3D
	if model is Mesh:
		var mesh := MeshInstance3D.new(); mesh.mesh = model
		add_child(mesh)
		mesh.set_owner(get_tree().edited_scene_root)
		mesh.name = model_name
		model_node = mesh
	elif model is PackedScene:
		var instanced: Node = model.instantiate()
		add_child(instanced)
		instanced.set_owner(get_tree().edited_scene_root)
		instanced.name = model_name
		model_node = instanced
	var col_shape: CollisionShape3D = get_child(0)
	var points: PackedVector3Array = col_shape.shape.points; points.sort()
	var size := points[points.size() - 1] - points[0]
	model_node.position = model_node.get_parent_node_3d().position
	model_node.position -= model_node.position.sign() * size * 0.5
	added_model_name = model_name

func _update_random_target() -> void:
	dir = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	target_position = start_position + spread * dir
	get_tree().create_timer(randf_range(5.0, 10.0)).timeout.connect(_update_random_target)

func _animate() -> void:
	var delta := get_process_delta_time()
	current_position = current_position.move_toward(target_position, delta * speed)
	model.position = current_position
	model.position.y += breathing_spread * sin(breathing_offset + (Time.get_ticks_msec() as float * 0.001 * breathing_speed))

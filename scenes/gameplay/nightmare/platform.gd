@tool
extends StaticBody3D
class_name NightmarePlatform

const MODEL_PATHS: Dictionary = {
	"simple": preload("res://assets/models/platform/simple.tres"),
	"triprism": preload("res://assets/models/platform/triprism.fbx"),
}

@export var spread := Vector3(0.3, 0.15, 0.3)
@export var speed := 0.1
@export var breathing_spread := 0.1
@export var breathing_speed := 1.0
@export var func_godot_properties: Dictionary
@export var added_models := false
@export var models := []

@onready var dir := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
@onready var breathing_offset := randf_range(-PI, PI)

@onready var start_position: Vector3 = position
@onready var current_position: Vector3 = start_position
@onready var target_position: Vector3 = start_position + spread * dir

func _func_godot_build_complete():
	if not added_models:
		for model_name in MODEL_PATHS.keys():
			var model = MODEL_PATHS[model_name]
			if model is Mesh:
				var mesh := MeshInstance3D.new(); mesh.mesh = model
				add_child(mesh); mesh.name = model_name
				models.append(mesh)
			elif model is PackedScene:
				var instanced: Node = model.instantiate()
				add_child(instanced); instanced.name = model_name
				models.append(instanced)
		added_models = true
	_update_model()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	scale_object_local(Vector3.ONE * randf_range(0.8, 1.3))
	rotation.y = randf_range(0, PI)
	get_tree().process_frame.connect(_animate)

func _update_model() -> void:
	var model_node: Node3D
	var model_name: String = func_godot_properties.get("model_name", "")
	if model_name.is_empty(): model_node = models.pick_random()
	else: model_node = get_node(model_name)
	var col_shape: CollisionShape3D = get_child(0)
	for model in models: model.visible = false
	model_node.visible = true
	var points: PackedVector3Array = col_shape.shape.points; points.sort()
	var size := points[points.size() - 1] - points[0]
	model_node.position = model_node.get_parent_node_3d().position
	model_node.position -= model_node.position.sign() * size * 0.5
	Loggie.info("test %s" % size)

func _update_random_target() -> void:
	dir = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	target_position = start_position + spread * dir
	get_tree().create_timer(randf_range(5.0, 10.0)).timeout.connect(_update_random_target)

func _animate() -> void:
	var delta := get_process_delta_time()
	current_position = current_position.move_toward(target_position, delta * speed)
	position = current_position
	position.y += breathing_spread * sin(breathing_offset + (Time.get_ticks_msec() as float * 0.001 * breathing_speed))

extends MeshInstance3D
class_name NightmarePlatform

@export var spread := Vector3(0.3, 0.15, 0.3)
@export var speed := 0.1
@export var breathing_spread := 0.1
@export var breathing_speed := 1.0

@onready var period := randf_range(5.0, 10.0)
var period_timer := 0.0
@onready var dir := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
@onready var breathing_offset := randf_range(-PI, PI)

@onready var start_position: Vector3 = position
@onready var current_position: Vector3 = start_position
@onready var target_position: Vector3 = start_position + spread * dir

func _ready() -> void:
	scale_object_local(Vector3.ONE * randf_range(0.8, 1.3))
	rotation.y = randf_range(0, PI)

func _process(delta: float) -> void:
	_move_pos(delta)
	current_position = current_position.move_toward(target_position, delta * speed)
	position = current_position
	position.y += breathing_spread * sin(breathing_offset + (Time.get_ticks_msec() as float * 0.001 * breathing_speed))

func _move_pos(delta: float) -> void:
	if period_timer < period:
		period_timer += delta
	else:
		target_position = start_position + spread * dir
		dir = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		period = randf_range(5.0, 10.0)
		period_timer = 0.0

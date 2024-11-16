@tool
extends Node3D
class_name Player

@export var func_godot_properties: Dictionary:
	set(props):
		func_godot_properties = props
		_update_with_props(func_godot_properties)

@export var can_interact: bool = true
@export var footstep_time: float = 1.0 / 2
var footstep_timer: float = 0.0
var footstep_switch: bool = false

var last_on_floor := true

const Controller := preload("res://addons/fpc/character.gd")
@onready var controller: Controller = %Controller

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_update_with_props(func_godot_properties)
	Scenes.change_pre_finish.connect(
		func(scene: Node):
			GameState.player = self
			get_tree().process_frame.connect(_check_interactable),
		CONNECT_ONE_SHOT,
	)
	get_tree().process_frame.connect(_process_footstep)
	get_tree().process_frame.connect(_process_land)
	controller.get_node("Neck/Head").rotation.y = global_rotation.y
	global_rotation.y = 0.0

func _process_land() -> void:
	if Engine.get_process_frames() % 5 != 0: return
	if not last_on_floor and controller.is_on_floor():
		%FootstepSfxR.play()
		%FootstepSfxL.play()
	last_on_floor = controller.is_on_floor()

func _process_footstep() -> void:
	var delta := get_process_delta_time()
	var has_input := not controller.get_input_dir().is_zero_approx()
	var is_on_floor := controller.is_on_floor()
	if is_on_floor and has_input:
		footstep_timer += delta * (controller.current_speed / controller.base_speed)
	if footstep_timer > footstep_time:
		if footstep_switch: %FootstepSfxR.play()
		else: %FootstepSfxL.play()
		footstep_timer = 0.0
		footstep_switch = not footstep_switch
	elif not is_on_floor or not has_input:
		footstep_timer = 0.0

func _check_interactable():
	if not can_interact: return
	
	var collided = controller.interact_ray.get_collider()
	
	if collided is Interactable and collided.enabled:
		if Input.is_action_just_pressed("gameplay_interact"):
			collided._on_interact(self)
		else:
			collided._on_interact_hover(self)
	else:
		UILayer.hide_interact_text()

func _update_with_props(props: Dictionary):
	if props["disable_quad"] and controller:
		controller.get_node("Neck/Head/Camera/MeshInstance3D").queue_free()

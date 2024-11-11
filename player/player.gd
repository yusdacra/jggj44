extends Node3D
class_name Player

@export var can_interact: bool = true
@export var footstep_time: float = 1.0 / 2
var footstep_timer: float = 0.0
var footstep_switch: bool = false

const Controller := preload("res://addons/fpc/character.gd")
@onready var controller: Controller = %Controller

var ui_layer: UiLayer = null

func _ready() -> void:
	# find ui layer
	Scenes.change_finished.connect(
		func(scene: Node):
			ui_layer = scene.ui_layer
			get_tree().process_frame.connect(_check_interactable),
		CONNECT_ONE_SHOT,
	)

func _process(delta: float) -> void:
	_process_footstep(delta)

func _process_footstep(delta: float) -> void:
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
		ui_layer.hide_interact_text()

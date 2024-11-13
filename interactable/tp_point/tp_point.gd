extends Interactable
class_name TpPoint

@export var destination: TpPoint:
	get():
		if destination == null:
			return Scenes.current.tp_points[func_godot_properties["destination"]]
		return destination
@export var snap_to_ground: bool = true
@export var fade_duration: float = 0.6 # seconds
@export var func_godot_properties: Dictionary

@onready var ground_ray: RayCast3D = %RayCast3D

func _ready() -> void:
	super()
	Scenes.change_finished.connect(
		func(scene: Node):
			scene.tp_points[func_godot_properties["tag"]] = self,
		CONNECT_ONE_SHOT,
	)

func _on_interact(player: Player) -> void:
	player.controller.immobile = true
	player.can_interact = false
	ui_layer.show_overlay()
	get_tree().create_timer(fade_duration).timeout.connect(
		func():
			_tp_to_destination(player)
			ui_layer.hide_overlay()
			player.controller.immobile = false
			player.can_interact = true
	)

func _tp_to_destination(player: Player) -> void:
	var dest := destination
	if snap_to_ground:
		dest.ground_ray.force_raycast_update()
		if dest.ground_ray.is_colliding():
			player.controller.global_position = dest.ground_ray.get_collision_point()
			return
	player.controller.global_position = dest.global_position

func _on_interact_hover(player: Player) -> void:
	ui_layer.show_interact_text("press F to enter")

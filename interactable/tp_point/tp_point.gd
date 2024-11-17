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
	Scenes.change_finished.connect(
		func(scene: Node):
			var tag: String = func_godot_properties["tag"]
			self.name = tag
			scene.tp_points[tag] = self,
		CONNECT_ONE_SHOT,
	)

func _on_interact(player: Player) -> void:
	player.controller.immobile = true
	player.can_interact = false
	UILayer.show_overlay()
	get_tree().create_timer(fade_duration * 0.3).timeout.connect(func(): Audio.play_sfx("DoorOpen"))
	get_tree().create_timer(fade_duration).timeout.connect(
		func():
			_tp_to_destination(player)
			UILayer.hide_overlay()
			player.controller.immobile = false
			player.can_interact = true
			GameState.last_used_tp_point = self.name
	)

func _tp_to_destination(player: Player) -> void:
	var dest := destination
	destination.enabled = false
	# failsafe for if the player doesnt leave the tp area for some reason
	get_tree().create_timer(1.0).timeout.connect(
		func(): destination.enabled = true
	)
	if snap_to_ground:
		dest.ground_ray.force_raycast_update()
		if dest.ground_ray.is_colliding():
			player.controller.global_position = dest.ground_ray.get_collision_point()
			return
	player.controller.global_position = dest.global_position

func _on_interact_hover(player: Player) -> void:
	UILayer.show_interact_text("press F to enter")


func _on_body_exited(body: Node3D) -> void:
	if body.get_parent() is Player: enabled = true

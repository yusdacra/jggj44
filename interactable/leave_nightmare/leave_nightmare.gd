extends Interactable

@export var func_godot_properties: Dictionary

var model: Node3D

func _ready() -> void:
	var model: Node3D = load("res://interactable/leave_nightmare/models/%s.tscn" % func_godot_properties["model_name"]).instantiate()
	add_child(model)
	self.model = model

func _process(delta: float) -> void:
	# breathing
	model.position.y = 0.3 * sin(Time.get_ticks_msec() * 0.001 * 2.0)

func _on_interact(player: Player):
	player.controller.immobile = true
	Game.change_scene_to_file("res://scenes/gameplay/gameplay.tscn", {"left_nightmare": true})

func _on_interact_hover(player: Player) -> void:
	UILayer.show_interact_text("press F to leave")

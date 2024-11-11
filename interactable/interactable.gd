extends Area3D
class_name Interactable

@export var object_name: String = "object"
@export var enabled: bool = true

@onready var ui_layer: UiLayer = null

func _ready() -> void:
	Scenes.change_finished.connect(
		func(scene: Node): ui_layer = scene.ui_layer,
		CONNECT_ONE_SHOT,
	)

func _on_interact(player: Player) -> void:
	pass

func _on_interact_hover(player: Player) -> void:
	ui_layer.show_interact_text("press F to interact with %s" % object_name)

extends Area3D
class_name Interactable

@export var interact_text: String = "press F to interact"
@export var enabled: bool = true

func _on_interact(player: Player) -> void:
	pass

func _on_interact_hover(player: Player) -> void:
	UILayer.show_interact_text(interact_text)

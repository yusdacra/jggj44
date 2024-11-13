extends CanvasLayer
class_name UiLayer

@onready var dialogue: DialogueBalloon = %DialogueBalloon

var target_interact_opacity := 0.0
var target_overlay_opacity := 0.0

func _ready() -> void:
	%InteractText.self_modulate.a = 0.0
	%Overlay.self_modulate.a = 0.0

func _process(delta: float) -> void:
	var modulate_by: float = delta * 3.0 * ((%InteractText.self_modulate.a * 3.0) + 1.0)
	%InteractText.self_modulate.a = move_toward(%InteractText.self_modulate.a, target_interact_opacity, modulate_by)
	modulate_by = delta * 2.0 * ((%Overlay.self_modulate.a * 2.0) + 1.0)
	%Overlay.self_modulate.a = move_toward(%Overlay.self_modulate.a, target_overlay_opacity, modulate_by)

func show_interact_text(text: String) -> void:
	%InteractText.text = "[center]%s" % text
	target_interact_opacity = 1.0

func hide_interact_text() -> void:
	target_interact_opacity = 0.0

func show_dialogue(dialogue: DialogueResource, title: String) -> void:
	%DialogueBalloon.start(dialogue, title)
	%DialogueBalloon.show()

func hide_dialogue() -> void:
	%DialogueBalloon.hide()

func show_overlay() -> void:
	target_overlay_opacity = 1.0

func hide_overlay() -> void:
	target_overlay_opacity = 0.0

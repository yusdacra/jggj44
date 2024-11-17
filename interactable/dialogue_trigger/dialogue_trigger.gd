extends Interactable
class_name DialogueTrigger

@export var func_godot_properties: Dictionary
@export var dialogue: DialogueResource
@export var dialogue_title: String

var mouse_mode_before: Input.MouseMode
var player_immobile_before: bool
var enabled_before: bool

func _ready() -> void:
	if func_godot_properties.has("dialogue_name") and func_godot_properties.has("title"):
		dialogue = load("res://dialogue/%s.dialogue" % func_godot_properties["dialogue_name"])
		dialogue_title = func_godot_properties["title"]
		if not func_godot_properties.get("interact_text", "").is_empty():
			interact_text = func_godot_properties.get("interact_text")

func _on_interact(player: Player) -> void:
	# remember the state before interacting so we can restore them later
	mouse_mode_before = Input.mouse_mode
	player_immobile_before = player.controller.immobile
	enabled_before = enabled
	# disable interactable, make player immobile, show dialogue
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	enabled = false
	player.controller.immobile = true
	UILayer.show_dialogue(dialogue, dialogue_title)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end.bind(player), CONNECT_ONE_SHOT)

func _on_dialogue_end(d: DialogueResource, player: Player):
	if dialogue != d: return
	Input.mouse_mode = mouse_mode_before
	player.controller.immobile = player_immobile_before
	get_tree().create_timer(0.2).timeout.connect(func(): enabled = enabled_before)

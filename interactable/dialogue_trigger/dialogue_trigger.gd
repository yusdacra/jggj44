extends Interactable
class_name DialogueTrigger

@export var dialogue: DialogueResource
@export var dialogue_title: String

var mouse_mode_before: Input.MouseMode
var player_immobile_before: bool
var enabled_before: bool

func _on_interact(player: Player) -> void:
	# remember the state before interacting so we can restore them later
	mouse_mode_before = Input.mouse_mode
	player_immobile_before = player.controller.immobile
	enabled_before = enabled
	# disable interactable, make player immobile, show dialogue
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	enabled = false
	player.controller.immobile = true
	ui_layer.show_dialogue(dialogue, dialogue_title)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end.bind(player), CONNECT_ONE_SHOT)

func _on_dialogue_end(d: DialogueResource, player: Player):
	if dialogue != d: return
	enabled = enabled_before
	player.controller.immobile = player_immobile_before
	Input.mouse_mode = mouse_mode_before

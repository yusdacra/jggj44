extends Interactable
class_name LightSwitchTrigger

@export var func_godot_properties: Dictionary:
	set(props):
		func_godot_properties = props
		_update_with_props()

@export var light_switch: LightSwitch
var target_light: Light3D

func _ready() -> void:
	Scenes.change_finished.connect(func(scene): _update_with_props(scene), CONNECT_ONE_SHOT)

func _update_with_props(scene: Node = null) -> void:
	light_switch.state = func_godot_properties["state"]
	if scene != null:
		target_light = scene.sp_lights[func_godot_properties["target"]]
		match light_switch.state:
			"open": target_light.light_energy = 0.0
			"closed": target_light.light_energy = target_light.on_energy

func _on_interact(player: Player):
	match light_switch.state:
		"open": light_switch.state = "closed"
		"closed": light_switch.state = "open"
	match light_switch.state:
		"open": target_light.light_energy = 0.0
		"closed": target_light.light_energy = target_light.on_energy
	Audio.play_sfx("LightSwitch")

func _on_interact_hover(player: Player):
	var act: String
	match light_switch.state:
		"open": act = "turn on light"
		"closed": act = "turn off light"
	UILayer.show_interact_text("press F to %s" % act)

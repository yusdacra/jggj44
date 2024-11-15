@tool
extends Node3D
class_name Curtain

@export var func_godot_properties: Dictionary:
	set(new_props):
		func_godot_properties = new_props
		_update_with_props(func_godot_properties)
@export var material: BaseMaterial3D = null
@export_enum("open", "closed", "partially_open") var state: String = "partially_open":
	set(new_state):
		get_node(state).visible = false
		state = new_state
		get_node(state).visible = true

func _ready() -> void:
	if material != null:
		_for_each_mesh(func(mesh: MeshInstance3D): mesh.material_override = material)
	_update_with_props(func_godot_properties)

func _for_each_mesh(f: Callable) -> void:
	for child: Node3D in get_children():
		var mesh: MeshInstance3D = child.get_child(0)
		f.call(mesh)

func _update_with_props(props: Dictionary):
	state = props.get("state", state)

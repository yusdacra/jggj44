@tool
extends Node3D
class_name FuncBook

const COLORS: Array[Color] = [
	Color.WHITE_SMOKE,
	Color.DARK_SLATE_GRAY,
	Color.SEA_GREEN,
	Color.ROYAL_BLUE,
	Color.BURLYWOOD,
	Color.CORAL,
	Color.CORNFLOWER_BLUE,
	Color.CRIMSON,
	Color.DARK_MAGENTA,
	Color.KHAKI,
	Color.SKY_BLUE,
	Color.FIREBRICK,
]

func _ready() -> void:
	if get_child_count() < 1: return
	var mesh_instance: MeshInstance3D = get_child(0)
	if mesh_instance == null: return
	for idx in mesh_instance.mesh.get_surface_count():
		var base_mat: StandardMaterial3D = mesh_instance.mesh.surface_get_material(idx)
		var mat: StandardMaterial3D = base_mat.duplicate()
		mat.albedo_color = COLORS.pick_random()
		mesh_instance.mesh.surface_set_material(idx, mat)

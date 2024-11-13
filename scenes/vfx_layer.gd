extends CanvasLayer
class_name Vfx

func _process(delta: float) -> void:
	var chaos: float = %Distort.material.get_shader_parameter("chaos")
	chaos = move_toward(chaos, 0.0, delta * (chaos + 0.1) * 5.0)
	%Distort.material.set_shader_parameter("chaos", chaos)

func set_chaos(v: float) -> void:
	%Distort.material.set_shader_parameter("chaos", v)

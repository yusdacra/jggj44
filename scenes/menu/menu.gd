extends Control

@export var btn_play: Button
@export var btn_exit: Button


func _ready():
	Audio.bgm.volume_db = linear_to_db(0.0)
	# needed for gamepads to work
	btn_play.grab_focus()
	if OS.has_feature("web"):
		btn_exit.queue_free()  # exit button dosn't make sense on HTML5


func _on_PlayButton_pressed() -> void:
	var params = {
		"show_progress_bar": false,
		"fade_music_in": true,
	}
	VfxLayer.set_chaos(32.0)
	Game.change_scene_to_file("res://scenes/gameplay/gameplay.tscn", params)


func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	var transitions = get_node_or_null("/root/Transitions")
	if transitions:
		transitions.fade_in({"show_progress_bar": false})
		await transitions.anim.animation_finished
		await get_tree().create_timer(0.3).timeout
	get_tree().quit()


func _on_play_button_mouse_entered() -> void:
	VfxLayer.set_chaos(5.0)


func _on_exit_button_mouse_entered() -> void:
	VfxLayer.set_chaos(5.0)

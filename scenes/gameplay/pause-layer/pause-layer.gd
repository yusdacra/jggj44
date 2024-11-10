extends CanvasLayer

@export var pause_action := "ui_pause"

func _ready():
	pause_hide()


func pause_show():
	show()


func pause_hide():
	hide()


func _unhandled_input(event):
	if event.is_action_pressed(pause_action):
		if get_tree().paused:
			resume()
		else:
			pause()
		get_viewport().set_input_as_handled()


func resume():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pause_hide()


func pause():
	%Resume.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	pause_show()


func _on_Resume_pressed():
	resume()


func _on_main_menu_pressed():
	Game.change_scene_to_file("res://scenes/menu/menu.tscn", {"show_progress_bar": false})

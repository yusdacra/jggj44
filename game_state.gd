extends Node
class_name GameStateAutoload

var player: Player = null:
	set(new_player):
		player = new_player
		player_set.emit(new_player)

var time: float = 0.0:
	set(new_time):
		time = fmod(new_time, 360.0) # rolls over after night
		time_changed.emit(time)
var light_intensity: float = 100.0: # start at 100, between 0 and 200
	set(new_intensity):
		light_intensity = new_intensity
		light_intensity_changed.emit(new_intensity)
var night_level: String = "1"

signal player_set(player: Player)
signal time_changed(new_time: float)
signal light_intensity_changed(new_intensity: float)

func _ready() -> void:
	time_changed.connect(func(time): Loggie.info("time changed to %s" % time))
	light_intensity_changed.connect(func(light_intensity): Loggie.info("light intensity changed to %s" % light_intensity))

func change_to_nightmare(which: String = "") -> void:
	var params := {"nightmare": night_level if which.is_empty() else which}
	Game.change_scene_to_file("res://scenes/gameplay/nightmare/nightmare.tscn", params)

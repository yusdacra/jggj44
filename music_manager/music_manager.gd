extends Node
class_name MusicManager

const MUTE_DB: float = -60.0

## add string -> audio stream pairs
@export var start_layer: String
@export var layers: Dictionary
@export var transitions: Array[LayerTransition]
@export var default_transition: LayerTransitionProperties

@onready var sync_stream: AudioStreamSynchronized = AudioStreamSynchronized.new()

var target_layer: String
var current_layer: String = "fallback"

enum TransitionPhase {
	None,
	FadeOut,
	FadeIn,
}
var transition_phase: TransitionPhase = TransitionPhase.None
var transition_properties: LayerTransitionProperties = null
var transition_timer: float = 0.0

var stream_indices: Dictionary = {}

func _ready() -> void:
	layers["fallback"] = AudioStream.new()
	sync_stream.stream_count = layers.size()
	var idx := 0
	for layer_tag in layers.keys():
		stream_indices[layer_tag] = idx
		sync_stream.set_sync_stream(idx, layers[layer_tag])
		sync_stream.set_sync_stream_volume(idx, MUTE_DB)
		idx += 1
	transition_to(start_layer)

func _process(delta: float) -> void:
	if current_layer == target_layer: return
	if transition_properties == null:
		transition_properties = find_transition_for(current_layer, target_layer)
	match transition_phase:
		TransitionPhase.None:
			transition_timer = 0.0
			transition_phase = TransitionPhase.FadeOut
			Loggie.info("starting BGM layer transition from %s to %s" % [current_layer, target_layer])
		TransitionPhase.FadeOut:
			if transition_timer > transition_properties.fade_out_duration:
				transition_timer = 0.0
				transition_phase = TransitionPhase.FadeIn
		TransitionPhase.FadeIn:
			if transition_timer > transition_properties.fade_in_duration:
				transition_timer = 0.0
				transition_phase = TransitionPhase.None
				current_layer = target_layer
				Loggie.info("BGM layer transition finished to %s" % current_layer)
	match transition_phase:
		TransitionPhase.None: return
		TransitionPhase.FadeOut:
			var pos: float = transition_timer / transition_properties.fade_out_duration
			var vol: float = lerpf(get_layer_volume(current_layer), transition_properties.fade_out_volume, pos)
			set_layer_volume(current_layer, maxf(vol, transition_properties.fade_out_volume))
		TransitionPhase.FadeIn:
			var pos: float = transition_timer / transition_properties.fade_in_duration
			var vol: float = lerpf(get_layer_volume(target_layer), transition_properties.fade_in_volume, pos)
			set_layer_volume(current_layer, vol)
	transition_timer += delta

func change_layer_volume_by(layer: String, delta: float) -> float:
	var stream_idx: int = stream_indices[layer]
	var vol := sync_stream.get_sync_stream_volume(stream_idx)
	vol = vol + delta
	sync_stream.set_sync_stream_volume(stream_idx, vol)
	return vol

func set_layer_volume(layer: String, volume: float):
	var stream_idx: int = stream_indices[layer]
	sync_stream.set_sync_stream_volume(stream_idx, volume)

func get_layer_volume(layer: String) -> float:
	var stream_idx: int = stream_indices[layer]
	return sync_stream.get_sync_stream_volume(stream_idx)

func find_transition_for(from: String, to: String) -> LayerTransitionProperties:
	for transition in transitions:
		if transition.can_reverse and transition.from_layer == to and transition.to_layer == from:
			return transition.properties
		elif transition.from_layer == from and transition.to_layer == to:
			return transition.properties
	return default_transition

func transition_to(layer: String):
	if not layers.has(layer):
		Loggie.error("BGM layer %s does not exist in layers" % layer)
		return
	target_layer = layer
	Loggie.info("BGM layer target set to %s" % target_layer)

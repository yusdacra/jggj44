extends Node

@export var dialogue_trigger: DialogueTrigger

var dialogue_resources: Array[DialogueResource] = []

func _ready() -> void:
	if not OS.is_debug_build(): queue_free(); return
	var dir := DirAccess.open("res://dialogue/")
	if dir.get_open_error() != OK:
		Loggie.error("cannot open dialogue folder: %s" % dir.get_open_error())
		return
	for file in dir.get_files():
		if file.ends_with(".dialogue"):
			dialogue_resources.append(load("res://dialogue/%s" % file))
	var all_resource_str := ""
	for diag_res in dialogue_resources:
		var path := diag_res.resource_path
		all_resource_str += "import \"%s\" as %s\n" % [path, path.get_file().get_basename()]
	all_resource_str += "~ all_diags\n"
	all_resource_str += "Bubble: here are all the dialogues in the game\n"
	for diag_res in dialogue_resources:
		var diag_name := diag_res.resource_path.get_file().get_basename()
		all_resource_str += "- %s\n" % diag_name
		for title in diag_res.get_titles():
			all_resource_str += "	- %s => %s/%s\n" % [title, diag_name, title]
	all_resource_str += "=> END\n"
	Loggie.info("all resources diag text:\n%s" % all_resource_str)
	var all_resource := DialogueManager.create_resource_from_text(all_resource_str)
	dialogue_trigger.dialogue = all_resource
	dialogue_trigger.dialogue_title = "all_diags"

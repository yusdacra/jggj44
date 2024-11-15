extends Interactable

@onready var curtain: Curtain = get_parent()

func _on_interact(player: Player):
	match curtain.state:
		"open": curtain.state = "partially_open"
		"partially_open": curtain.state = "closed"
		"closed": curtain.state = "open"

func _on_interact_hover(player: Player):
	var act: String
	match curtain.state:
		"open": act = "dim"
		"partially_open": act = "close"
		"closed": act = "open"
	UILayer.show_interact_text("press F to %s" % act)

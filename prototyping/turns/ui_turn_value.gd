extends Label

@onready
var turn_manager = owner.get_node("TurnManager")

func _ready():
	turn_manager.connect('next_turn', func(actor):
		text = actor.name
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

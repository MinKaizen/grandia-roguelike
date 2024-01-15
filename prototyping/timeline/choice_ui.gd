extends Control

@onready var timeline = get_tree().get_first_node_in_group('timeline')

func _ready():
	timeline.connect('player_to_act', func():
		get_tree().paused = true
	)

func _process(delta):
	pass

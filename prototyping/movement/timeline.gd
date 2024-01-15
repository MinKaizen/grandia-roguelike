extends Control

const MAX_PROGRESS = 100.0
const MIN_PROGRESS = 0.0
@onready var start_position = $Start.position
@onready var end_position = $End.position
@onready var actors: Array = get_tree().get_nodes_in_group('timeline_actor')

func _ready() -> void:
	for actor in actors:
		var marker = actor.marker_scene.instantiate()
		self.add_child(marker)
		marker.init(actor)

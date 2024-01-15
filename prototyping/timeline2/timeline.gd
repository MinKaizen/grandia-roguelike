extends Node

signal player_to_act

const MAX_PROGRESS = 100.0
const MIN_PROGRESS = 0.0
@export var marker_scene: PackedScene
@onready var start_position = $Start.position
@onready var end_position = $End.position
@onready var actors: Array = get_tree().get_nodes_in_group('temp_timeline_marker_owner')

func _ready() -> void:
	for actor in actors:
		var marker = actor.owner.get_node('CustomMarker').instantiate() if actor.owner.has_node('CustomMarker') else marker_scene.instantiate()
		self.add_child(marker)
		marker.init(actor)
		

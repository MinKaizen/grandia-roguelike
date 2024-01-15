extends Control

const MAX_ACTION_POINTS = 100.0

var actors: Array

@onready var wait_start = $WaitStart.position
@onready var wait_end = $WaitEnd.position
@onready var channel_start = $ChannelStart.position
@onready var channel_end = $ChannelEnd.position

func _ready():
	actors = get_tree().get_nodes_in_group('timeline_actor').filter(func(item):
		var has_timeline_marker = 'timeline_marker' in item and item.timeline_marker is PackedScene
		var has_signal = 'action_points_updated' in item and item.action_points_updated is Signal
		return has_timeline_marker and has_signal
	)
	for actor in actors:
		var marker = actor.timeline_marker.instantiate()
		self.add_child(marker)
		marker.position = calculate_position(actor.action_points)
		actor.connect('action_points_updated', func(action_points):
			marker.position = calculate_position(action_points)
		)

func calculate_position(action_points: float):
	return wait_start.lerp(wait_end, min(1, action_points / MAX_ACTION_POINTS))

func _physics_process(delta):
	pass

extends Control

signal time_to_act

const UI_SPEED = 700.0
const RESTART_OFFSET := Vector2(-200.0, 0)

var progress: float = 0.0
var pos_offset := Vector2.ZERO
var actor: Node
var timeline: Node

func init(actor: Node, timeline: Node):
	self.actor = actor
	self.timeline = timeline
	actor.connect('progress_updated', func(new_progress):
		progress = new_progress
	)
	actor.connect('restarted', func():
		restart()
	)
	position = calculate_position(actor.get_progress())
	restart()

func calculate_position(new_progress: float):
	var completion = new_progress / actor.MAX_PROGRESS
	return timeline.start_position + (timeline.end_position - timeline.start_position) * completion

func _process(delta):
	update_ui(delta)

func update_ui(delta):
	var new_position = calculate_position(progress)
	position = position.move_toward(new_position + pos_offset, UI_SPEED * delta)

func restart() -> void:
	self.modulate = Color.TRANSPARENT
	self.pos_offset = RESTART_OFFSET
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'modulate', Color.WHITE, 1)
	tween.parallel().tween_property(self, 'pos_offset', Vector2.ZERO, 1)

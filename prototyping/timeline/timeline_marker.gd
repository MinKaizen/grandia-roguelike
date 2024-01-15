extends Control

signal time_to_act

const UI_SPEED = 300.0
const RESTART_OFFSET := Vector2.LEFT * 100

var actor: Node
var progress: float

@onready var timeline = get_parent()

func _ready():
	set_process(false)
	position = timeline.start_position

func init(actor: Node, progress: float = 0.0):
	self.actor = actor
	self.progress = progress
	self.connect('time_to_act', func():
		actor._on_time_to_act()
	)
	set_process(true)

func _process(delta):
	update_progress(delta)
	update_ui(delta)
	if progress >= timeline.MAX_PROGRESS:
		print('Time to act: %s' % actor.name)
		emit_signal('time_to_act', actor)
		restart()

func update_progress(delta):
	progress = clamp(progress + actor.timeline_speed * delta, timeline.MIN_PROGRESS, timeline.MAX_PROGRESS) 
	

func update_ui(delta):
	var completion = progress / timeline.MAX_PROGRESS
	var new_position = timeline.start_position + (timeline.end_position - timeline.start_position) * completion
	position = position.move_toward(new_position, UI_SPEED * delta)

func restart() -> void:
	position = timeline.start_position + RESTART_OFFSET
	progress = 0.0
	self.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'modulate', Color.WHITE, 1)

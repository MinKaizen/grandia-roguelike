extends Control

signal time_to_act

const UI_SPEED = 400.0
const RESTART_OFFSET := -200.0

var progress: float = 0.0
var pos_offset: float = 0.0
@onready var timeline: Node

func _ready():
	set_process(false)

func init(actor: Node):
	timeline = get_tree().get_first_node_in_group('timeline')
	actor.connect('progress_updated', Callable(self, '_on_progress_updated'))
	actor.connect('restarted', Callable(self, 'restart'))
	restart()
	set_process(true)

func _on_progress_updated(progress):
	self.progress = progress

func _process(delta):
	update_ui(delta)
	
func update_ui(delta):
	var completion = progress / timeline.MAX_PROGRESS
	var new_position = timeline.start_position + (timeline.end_position - timeline.start_position) * completion
	position = new_position + Vector2(pos_offset, 0)

func restart() -> void:
	self.modulate = Color(1, 1, 1, 0)
	self.pos_offset = RESTART_OFFSET
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'modulate', Color.WHITE, 1)
	tween.parallel().tween_property(self, 'pos_offset', 0.0, 1)

extends Node

signal progress_updated
signal ready_to_select
signal casting
signal ready_to_act
signal restarted

@export var marker: PackedScene

const NO_PROGRESS = 0.0
const DEFAULT_BOOST = 0.0
const SELECT_POINT = 100.0
const MAX_PROGRESS = 140.0
const ACT_POINT = MAX_PROGRESS

enum STATE {WAITING, SELECTING, CASTING, ACTING}

var state = STATE.WAITING
var progress: float = NO_PROGRESS

func _ready():
	var timeline = get_tree().get_first_node_in_group('timeline')
	if marker and timeline:
		var new_marker = marker.instantiate()
		timeline.add_child(new_marker)
		new_marker.init(self, timeline)

func get_progress():
	return progress

func add_progress(amount: float):
	set_progress(progress + amount)

func reduce_progress(amount: float):
	set_progress(progress - amount)

func set_progress(amount: float):
	progress = clamp(amount, NO_PROGRESS, MAX_PROGRESS)
	emit_signal('progress_updated', progress)
	update_state()

func update_state():
	match state:
		STATE.WAITING:
			_waiting_update_state()
		STATE.SELECTING:
			_selecting_update_state()
		STATE.CASTING:
			_casting_update_state()
		STATE.ACTING:
			_acting_update_state()

func _waiting_update_state():
	if progress >= SELECT_POINT:
		progress = SELECT_POINT
		state = STATE.SELECTING
		emit_signal('ready_to_select')

func _selecting_update_state():
	if progress >= ACT_POINT:
		progress = ACT_POINT
		state = STATE.ACTING
		emit_signal('ready_to_act')
	elif progress > SELECT_POINT:
		state = STATE.CASTING
		emit_signal('casting')

func _casting_update_state():
	if progress >= ACT_POINT:
		progress = ACT_POINT
		state = STATE.ACTING
		emit_signal('ready_to_act')

func _acting_update_state():
	if progress < ACT_POINT:
		state = STATE.WAITING
		emit_signal('restarted')

class_name TimelineActor extends Node

signal progress_updated
signal restarted
signal speed_updated
signal state_changed

@export var speed: float = 10.0

enum STATE {IDLE, COMBAT, ACT}

const MAX_PROGRESS: float = 100.0
const MIN_PROGRESS: float = 0.0
const COMBAT_POINT: float = 70.0
const ACT_POINT: float = MAX_PROGRESS
const DEFAULT_RESTART_BOOST: float = 10.0

var progress: float = 0.0 : set = set_progress
var state: int

func _ready() -> void:
	update_state()
	get_parent().connect('act_finished', Callable(self, 'restart'))

func _process(delta):
	set_progress(progress + speed * delta)

func set_progress(new_progress: float) -> void:
	progress = clamp(new_progress, MIN_PROGRESS, MAX_PROGRESS)
	emit_signal('progress_updated', progress)
	update_state()

func update_state() -> void:
	var old_state = state
	
	if progress >= ACT_POINT:
		state = STATE.ACT
	elif progress >= COMBAT_POINT:
		state = STATE.COMBAT
	else:
		state = STATE.IDLE
	
	if old_state != state:
		emit_signal('state_changed', state)

func set_speed(value: float) -> void:
	speed = value
	emit_signal('speed_updated', speed)

func restart(offset: float = DEFAULT_RESTART_BOOST) -> void:
	progress = MIN_PROGRESS + offset
	emit_signal('restarted')

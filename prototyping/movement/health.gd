extends Node

signal health_increased
signal health_decreased
signal max_health_increased
signal max_health_decreased
signal health_empty
signal health_full

const MIN = 0
@export var max: int = 100
var current: int = max : set = set_health, get = get_health

func get_health():
	return current

func set_health(amount: int):
	var previous = current
	current = clamp(amount, MIN, max)
	if current > previous:
		emit_signal('health_increased')
		if current == max:
			emit_signal('health_full')
	elif current < previous:
		emit_signal('health_decreased')
		if current == MIN:
			emit_signal('health_empty')
	print('health: %s' % current)

func set_health_fraction(percentage: float):
	current = roundf(percentage * max)

func reduce_health(amount: int):
	current -= amount

func increase_health(amount: int):
	current += amount


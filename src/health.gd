extends Node

signal health_increased
signal health_reduced
signal max_health_increased
signal max_health_reduced
signal health_empty
signal health_full
signal overkill
signal overheal

const MIN: int = 0
@export var max: int = 100
var current: int = max

func get_health():
	return current

func set_health_fraction(percentage: float):
	set_health(roundf(percentage * max))

func reduce_health(amount: int):
	set_health(current - amount)

func increase_health(amount: int):
	set_health(current + amount)

func set_health(new: int):
	var previous = current
	current = clamp(new, MIN, max)
	if current > previous:
		emit_signal('health_increased', current - previous)
		if new > max:
			print({
				'new': new,
				'max': max,
			})
			emit_signal('overheal', new - max)
		if current == max:
			emit_signal('health_full')
	elif current < previous:
		emit_signal('health_reduced', -current + previous)
		if new < 0:
			emit_signal('overkill', -new)
		if current == MIN:
			emit_signal('health_empty')

func get_max_health():
	return max

func increase_max_health(amount: int):
	set_max_health(max + amount)

func reduce_max_health(amount: int):
	set_max_health(max - amount)

func set_max_health(new: int):
	var previous = max
	max = max(new, 1)
	
	if max < previous:
		emit_signal('max_health_reduced', previous - max)
	elif max > previous:
		emit_signal('max_health_increased', max - previous)
	
	if current > max:
		set_health(max)

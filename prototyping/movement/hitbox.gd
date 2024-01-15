extends Area3D

signal hit

func take_hit(hit_info):
	# TODO: extra calculations
	emit_signal('hit', hit_info)

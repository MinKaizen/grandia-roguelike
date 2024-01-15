extends Node3D

@export var bullet_scene: PackedScene

func emit():
	var target = get_tree().get_first_node_in_group('player')
	if not target is Node3D:
		return
	var direction = (target.global_position - global_position).normalized()
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = global_position
	bullet.init(direction)

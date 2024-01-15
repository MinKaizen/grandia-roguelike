extends Node

signal finished

@export var nav: NavigationAgent3D
@export var actor: Node
@export_range(0.0, 5.0) var target_distance: float = 0.5
@onready var target: Vector3 = actor.global_position

func _ready():
	set_physics_process(false)

func execute(new_target: Vector3):
	target = new_target
	set_physics_process(true)

func _physics_process(delta):
	nav.target_position = target
	var offset = nav.get_next_path_position() - actor.global_position
	offset.y = 0
	var direction = offset.normalized()
	actor.velocity = actor.velocity.lerp(direction * actor.speed, actor.acceleration * delta)
	if pseudo_arrived():
		_finished()
		emit_signal('finished')

func _finished():
	actor.velocity = Vector3.ZERO
	set_physics_process(false)

func pseudo_arrived() -> bool:
	return actor.global_position.distance_to(target) <= 0.5

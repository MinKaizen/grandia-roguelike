extends CharacterBody3D

signal choice_time
signal action_points_updated

@export var max_speed: float = 5.0
@export var acceleration: float = 40.0
@export var action_points: float = 0.0:
	set(value):
		action_points = value
		emit_signal('action_points_updated', action_points)
@export var action_speed: float = 100.0
@export var timeline_marker: PackedScene

var speed: float = 0.0
var stuck_duration: float = 0.0
var max_stuck_duration: float = 1.0
var direction: Vector3 = Vector3.ZERO
var target_position: Vector3 = global_position

@onready var camera = get_tree().get_first_node_in_group('camera')
@onready var state = $State

func _on_waiting_state_entered():
	action_points = 0.0

func _on_waiting_state_physics_processing(delta):
	action_points += action_speed * delta
	if action_points >= 100:
		select_command()

func select_command():
	target_position = random_position()
	state.send_event('move_selected')

func random_position() -> Vector3:
	return Vector3(randf_range(-5, 5), 0, randf_range(-8, 8))

func _on_waiting_state_exited():
	pass

func _on_moving_state_entered():
	pass # Replace with function body.

func _on_moving_state_physics_processing(delta):
	if global_position.distance_to(target_position) <= 0.05:
		state.send_event('move_completed')
	direction = (target_position - global_position).normalized()
	var slow_factor = min(1, lerp(0, 1, global_position.distance_to(target_position)))
	speed = move_toward(speed, max_speed * slow_factor, acceleration * delta)
	if speed >= 0.2 * max_speed:
		rotation.y = -direction.signed_angle_to(Vector3(0,0,1), Vector3.UP)
	velocity = speed * direction
	move_and_slide()

func _on_moving_state_exited():
	speed = 0
	velocity = Vector3.ZERO
	stuck_duration = 0
	target_position = global_position

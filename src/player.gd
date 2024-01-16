extends CharacterBody3D

signal choice_time
signal action_points_updated
signal animation_attack_landed

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
var attack_target: Node3D

@onready var camera = get_tree().get_first_node_in_group('camera')
@onready var choice_ui = get_tree().get_first_node_in_group('choice_ui')
@onready var state = $State
@onready var animation = $AnimationPlayer

func _ready():
	choice_ui.connect('choice_selected', func(actor:Node, command: String, target):
		if not actor == self:
			return
		elif command == 'move' and target is Vector3:
			target_position = target
			state.send_event('move_selected')
		elif command == 'attack' and target is Node3D:
			attack_target = target
			state.send_event('attack_selected')
	)
	self.connect('animation_attack_landed', func():
		if attack_target is Node and 'receive_hit' in attack_target:
			attack_target.receive_hit({
				'damage': randi_range(34, 49),
				'attacker': self,
				'knockback': 1.5,
			})
	)

func get_target_position(mouse_position: Vector2) -> Vector3:
	var ray_length = 9999
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query)
	return result.position

func _on_waiting_state_entered():
	action_points = 0.0

func _on_waiting_state_physics_processing(delta):
	action_points += action_speed * delta
	if action_points >= 100:
		choice_ui.appear(self)

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

func _on_attack_moving_state_physics_processing(delta):
	if global_position.distance_to(attack_target.global_position) <= 1.2:
		state.send_event('attack_target_reached')
	direction = (attack_target.global_position - global_position).normalized()
	speed = move_toward(speed, max_speed, acceleration * delta)
	if speed >= 0.2 * max_speed:
		rotation.y = -direction.signed_angle_to(Vector3(0,0,1), Vector3.UP)
	velocity = speed * direction
	move_and_slide()

func _on_attack_moving_state_exited():
	speed = 0
	velocity = Vector3.ZERO

func _on_attack_attacking_state_entered():
	animation.play("bump")
	await animation.animation_finished
	state.send_event('attack_completed')

func _on_attack_attacking_state_physics_processing(delta):
	direction = (attack_target.global_position - global_position).normalized()
	speed = move_toward(speed, max_speed, acceleration * delta)
	if speed >= 0.2 * max_speed:
		rotation.y = -direction.signed_angle_to(Vector3(0,0,1), Vector3.UP)
	velocity = speed * direction
	move_and_slide()

func _on_attack_attacking_state_exited():
	speed = 0
	velocity = Vector3.ZERO
	animation.play('RESET')

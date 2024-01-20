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
var received_hit: Dictionary
var attack_target: Node3D

@onready var camera = get_tree().get_first_node_in_group('camera')
@onready var state = $State
@onready var animation = $AnimationPlayer
@onready var health = $Health
@onready var damage_number_scene: PackedScene = preload("res://src/damage_number.tscn")

func _ready():
	animation.connect('animation_finished', func(anim_name: String):
		if anim_name == 'flinch':
			state.send_event('flinch_completed')
	)
	self.connect('animation_attack_landed', func():
		if attack_target is Node and 'receive_hit' in attack_target:
			attack_target.receive_hit({
				'damage': randi_range(13, 25),
				'attacker': self,
				'knockback': 1.5,
			})
	)

func receive_hit(hit):
	var is_flinchable = true
	received_hit = hit
	var damage_number = damage_number_scene.instantiate()
	get_tree().root.add_child(damage_number)
	damage_number.init(hit.damage, self.global_position, camera)
	health.reduce_health(hit.damage)
	if health.get_health() <= 0:
		state.send_event('die')
	elif is_flinchable:
		state.send_event('flinch')

func _on_waiting_state_entered():
	action_points = 0.0

func _on_waiting_state_physics_processing(delta):
	action_points += action_speed * delta
	if action_points >= 100:
		select_command()

func select_command():
	var target = random_target()
	if target is Node3D:
		attack_target = target
		state.send_event('attack_selected')
	else:
		target_position = random_position()
		state.send_event('move_selected')

func random_position() -> Vector3:
	return Vector3(randf_range(-5, 5), 0, randf_range(-8, 8))

func random_target():
	var targets = get_tree().get_nodes_in_group('player')
	if targets.size() > 0:
		return targets[randi_range(0, targets.size() - 1)]
	return null

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
		rotate_to(direction)
	velocity = speed * direction
	move_and_slide()

func rotate_to(direction_to_face: Vector3):
	rotation.y = -direction_to_face.signed_angle_to(Vector3(0,0,1), Vector3.UP)

func _on_moving_state_exited():
	speed = 0
	velocity = Vector3.ZERO
	stuck_duration = 0

func _on_flinch_state_entered():
#	rotate_to(received_hit.attacker.global_position - self.global_position)
	if 'knockback' in received_hit:
		knockback(received_hit.attacker.global_position, received_hit.knockback)
#		global_position += (global_position - received_hit.attacker.global_position).normalized() * received_hit.knockback
	animation.stop()
	animation.play('flinch')

func _on_flinch_state_exited():
	pass

func _on_die_state_entered():
#	rotate_to(received_hit.attacker.global_position - self.global_position)
	if 'knockback' in received_hit:
		knockback(received_hit.attacker.global_position, received_hit.knockback)
#		global_position += (global_position - received_hit.attacker.global_position).normalized() * received_hit.knockback
	animation.play('die')
	await animation.animation_finished
	queue_free()


func knockback(from_position: Vector3, distance: float = 0.0):
	from_position.y = 0
	var pos_2d = global_position
	pos_2d.y = 0
	var direction: Vector3
	if from_position == pos_2d:
		direction = Vector3.RIGHT.rotated(Vector3.UP, randf_range(0, 2 * PI))
	else:
		direction = (pos_2d - from_position).normalized()
	self.global_position += direction * distance
	self.rotate_to(-direction)

func _on_pursuing_state_entered():
	pass

func _on_pursuing_state_physics_processing(delta):
	if global_position.distance_to(attack_target.global_position) <= 2:
		state.send_event('target_reached')
	direction = (attack_target.global_position - global_position).normalized()
	speed = move_toward(speed, max_speed, acceleration * delta)
	if speed >= 0.2 * max_speed:
		rotation.y = -direction.signed_angle_to(Vector3(0,0,1), Vector3.UP)
	velocity = speed * direction
	move_and_slide()

func _on_pursuing_state_exited():
	pass

func _on_hitting_state_entered():
	animation.play("bump")
	await animation.animation_finished
	state.send_event('hit_completed')

func _on_hitting_state_physics_processing(delta):
	direction = (attack_target.global_position - global_position).normalized()
	speed = move_toward(speed, max_speed, acceleration * delta)
	if speed >= 0.2 * max_speed:
		rotate_to(direction)
	velocity = speed * direction
	move_and_slide()

func _on_hitting_state_exited():
	speed = 0
	velocity = Vector3.ZERO
	animation.play('RESET')

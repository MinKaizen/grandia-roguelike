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
var received_hit: Dictionary
var channel_time_elapsed: float
var channel_duration: float
var explosion_already_hit = []

@onready var camera = get_tree().get_first_node_in_group('camera')
@onready var choice_ui = get_tree().get_first_node_in_group('choice_ui')
@onready var state = $State
@onready var health = $Health
@onready var animation = $AnimationPlayer
@onready var damage_number_scene: PackedScene = preload("res://src/damage_number.tscn")
@onready var channeling_particles = $ChannelingParticles
@onready var explosion: Node = preload("res://src/explosion.tscn").instantiate()

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
		elif command == 'aoe_spell' and target is Node3D:
			attack_target = target
			state.send_event('aoe_spell_selected')
	)
	animation.connect('animation_finished', func(anim_name: String):
		if anim_name == 'flinch':
			state.send_event('flinch_completed')
	)
	self.connect('animation_attack_landed', func():
		if attack_target is Node and 'receive_hit' in attack_target:
			attack_target.receive_hit({
				'damage': randi_range(34, 49),
				'attacker': self,
				'knockback': 1.5,
			})
	)
#	get_tree().get_root().connect('ready', func(): 
#		get_tree().get_root().add_child(explosion)
#	)
	explosion.connect('body_entered', func(body):
		if body.is_in_group('enemy') and 'receive_hit' in body and body not in explosion_already_hit:
			body.receive_hit({
				'damage': randi_range(34, 49),
				'attacker': explosion,
				'knockback': 1.5,
			})
			print(body.global_position)
			explosion_already_hit.append(body)
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

func rotate_to(direction_to_face: Vector3):
	rotation.y = -direction_to_face.signed_angle_to(Vector3(0,0,1), Vector3.UP)

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
	animation.play('RESET')

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
#		rotation.y = -direction.signed_angle_to(Vector3(0,0,1), Vector3.UP)
		rotate_to(direction)
	velocity = speed * direction
	move_and_slide()

func _on_moving_state_exited():
	speed = 0
	velocity = Vector3.ZERO
	stuck_duration = 0
	target_position = global_position

func _on_attack_moving_state_physics_processing(delta):
	if global_position.distance_to(attack_target.global_position) <= 2:
		state.send_event('attack_target_reached')
	direction = (attack_target.global_position - global_position).normalized()
	speed = move_toward(speed, max_speed, acceleration * delta)
	if speed >= 0.2 * max_speed:
		rotation.y = -direction.signed_angle_to(Vector3(0,0,1), Vector3.UP)
	velocity = speed * direction
	move_and_slide()

func _on_attack_moving_state_exited():
	pass

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

func _on_flinch_state_entered():
#	rotate_to(received_hit.attacker.global_position - self.global_position)
	if 'knockback' in received_hit:
		knockback(received_hit.attacker.global_position, received_hit.knockback)
#		global_position += (global_position - received_hit.attacker.global_position).normalized() * received_hit.knockback
	animation.stop()
	animation.play('flinch')

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

func _on_channeling_state_entered():
	channel_time_elapsed = 0
	channel_duration = 3
	channeling_particles.emitting = true
	animation.play('channel')

func _on_channeling_state_physics_processing(delta):
	channel_time_elapsed += delta
	rotate_to(attack_target.global_position - self.global_position)
	if channel_time_elapsed >= channel_duration:
		state.send_event('channel_completed')

func _on_channeling_state_exited():
	channeling_particles.emitting = false
	channel_time_elapsed = 0

func _on_casting_state_entered():
	if not explosion.get_parent():
		get_tree().get_root().add_child(explosion)
	explosion_already_hit = []
	explosion.monitoring = true
	animation.play('cast')
	explosion.global_position = attack_target.global_position
	explosion.global_position.y = -10
	explosion.scale = Vector3.ZERO
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(explosion, 'scale', Vector3.ONE, 1)
	tween.parallel().tween_property(explosion, 'global_position:y', 0, 1)
	await tween.finished
	explosion.monitoring = false
	explosion.scale = Vector3.ZERO
	explosion.global_position.y = -10
	state.send_event('cast_completed')

func _on_casting_state_physics_processing(delta):
	pass

func _on_casting_state_exited():
	pass

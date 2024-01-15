extends CharacterBody3D

signal act_finished
signal choice_time

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed := 20.0
var acceleration := 50.0
@onready var move_to_position := global_position
@onready var nav = $NavAgent
@onready var choice_ui = $ChoiceUI
@onready var animation = $AnimationPlayer
@onready var health = $Health
@onready var hitbox = $Hitbox
enum STATE {IDLE, MOVING, ATTACKING}
var state = STATE.IDLE
var attack_target: Node
var attack_target_in_range := false

func _ready():
#	$TimelineActor.connect('state_changed', func(state: TLA2.STATE):
#		if state == TLA2.STATE.COMBAT:
#			emit_signal('choice_time')
#	)
	choice_ui.connect('choice_selected', func(selection, target = null):
		print('%s: selected [%s] [%s]' % [name, selection, target])
		if selection == 'move':
			state = STATE.MOVING
			move_to_position = target
		elif selection == 'attack':
			state = STATE.ATTACKING
			attack_target = target
			attack_target_in_range = false
	)
	hitbox.connect('hit', func(hit_info):
		var damage = hit_info.damage
		health.reduce_health(damage)
	)
	health.connect('health_empty', func():
		print('%s: died!' % name)
		animation.play('die')
		await animation.animation_finished
		queue_free()
	)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	match state:
		STATE.MOVING:
			_moving(delta)
		STATE.IDLE:
			_idle(delta)
		STATE.ATTACKING:
			_attacking(delta)
		_:
			pass

	move_and_slide()

func _idle(delta):
	pass

func _moving(delta):
	nav.target_position = move_to_position
	var direction = (nav.get_next_path_position() - global_position).normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	
	if global_position.distance_to(move_to_position) <= 3:
		velocity = Vector3.ZERO
		state = STATE.IDLE
		emit_signal('act_finished')

func _attacking(delta):
	nav.target_position = attack_target.global_position
	var direction = (nav.get_next_path_position() - global_position).normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	
	if not attack_target_in_range and global_position.distance_to(attack_target.global_position) <= 5:
		attack_target_in_range = true
		animate_attack()

func animate_attack():
	animation.play('attack')
	await animation.animation_finished
	velocity = Vector3.ZERO
	state = STATE.IDLE
	attack_target = null
	emit_signal('act_finished')

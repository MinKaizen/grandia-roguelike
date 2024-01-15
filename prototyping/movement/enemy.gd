extends CharacterBody3D

signal act_finished

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const FLOOR_BOTTOM_LEFT = Vector3(-30, 1, -5)
const FLOOR_TOP_RIGHT = Vector3(30, 1, 5)
var speed := 20.0
var acceleration := 50.0
@onready var move_to_position := Vector3.ZERO
@onready var nav = $NavAgent
@onready var animation = $AnimationPlayer
enum STATE {IDLE, MOVING, ATTACKING}
var state = STATE.IDLE

func _ready():
	$TimelineActor.connect('state_changed', func(state: TLA2.STATE):
		if state == TLA2.STATE.COMBAT:
#			self.state = STATE.MOVING
#			move_to_position = rand_position()
			$TimelineActor.set_progress(100.0)
			self.state = STATE.ATTACKING
			animation.play('attack')
			await animation.animation_finished
			self.state = STATE.IDLE
			emit_signal('act_finished')
	)
	

func rand_position() -> Vector3:
	var x = randf_range(FLOOR_BOTTOM_LEFT.x, FLOOR_TOP_RIGHT.x)
	var y = global_position.y
	var z = randf_range(FLOOR_BOTTOM_LEFT.z, FLOOR_TOP_RIGHT.z)
	return Vector3(x, y, z)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if state == STATE.IDLE:
		_idle(delta)
	elif state == STATE.MOVING:
		_moving(delta)
	elif state == STATE.ATTACKING:
		_attacking(delta)

	move_and_slide()

func _moving(delta):
	nav.target_position = move_to_position
	var direction = (nav.get_next_path_position() - global_position).normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	
	if global_position.distance_to(move_to_position) <= 3:
		velocity = Vector3.ZERO
		state = STATE.IDLE
		emit_signal('act_finished')

func _attacking(delta):
	pass

func _idle(delta):
	pass

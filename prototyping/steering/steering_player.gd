extends CharacterBody3D

enum STATE {IDLE, MOVING, STUCK}
const STUCK_SPEED = 0.1

var speed = 10.0
var accel = 20

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3
var rotation_speed = 2 * PI
var target_position = global_position
var is_stuck = false
var desired_direction = Vector3.ZERO
var state = STATE.IDLE


@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var camera: Camera3D = $"../Camera3D"

func _physics_process(delta):
	match state:
		STATE.IDLE:
			_on_idle(delta)
		STATE.MOVING:
			_on_moving(delta)
		STATE.STUCK:
			_on_stuck(delta)
		_:
			print('not in a valid state')
#	nav.target_position = target_position
#	var new_direction = nav.get_next_path_position() - global_position
#	new_direction = new_direction.normalized()
#	direction = new_direction
#	velocity = velocity.lerp(direction * speed, accel * delta)
#	if velocity.length() >= 0.5 * speed:
#		rotation.y = -direction.signed_angle_to(Vector3(0,0,1), Vector3.UP)
		

func _on_idle(delta):
	var pos_2d = Vector2(global_position.x, global_position.z)
	var target_pos_2d = Vector2(target_position.x, target_position.z)
	if pos_2d.distance_to(target_pos_2d) > 0.1:
		print('idle --> moving')
		state = STATE.MOVING

func _on_moving(delta):
	var pos_2d = Vector2(global_position.x, global_position.z)
	var target_pos_2d = Vector2(target_position.x, target_position.z)

	nav.target_position = target_position
	nav.target_position.y = global_position.y
	var new_direction = nav.get_next_path_position() - global_position
	new_direction = new_direction.normalized()
	direction = new_direction
	velocity = direction * speed
#	velocity = velocity.lerp(direction * speed, accel * delta)
	if velocity.length() >= 0.5 * speed:
		rotation.y = -direction.signed_angle_to(Vector3(0,0,1), Vector3.UP)
	
	move_and_slide()
	
	if pos_2d.distance_to(target_pos_2d) <= 0.1:
		print('moving --> idle')
		state = STATE.IDLE
	elif get_real_velocity().length() <= STUCK_SPEED:
		print('moving --> stuck')
		desired_direction = (nav.get_next_path_position() - global_position).normalized()
		state = STATE.STUCK

func _on_stuck(delta):
	desired_direction = desired_direction.rotated(Vector3.UP, PI * delta).normalized()
	velocity = desired_direction * speed
	move_and_slide()
	print(velocity.length())
	var pos_2d = Vector2(global_position.x, global_position.z)
	var target_pos_2d = Vector2(target_position.x, target_position.z)
#	if pos_2d.distance_to(target_pos_2d) <= 0.1:
#		print('stuck --> idle')
#		state = STATE.IDLE
	if velocity.length() >= 0.9 * speed:
		print('stuck --> moving')
		state = STATE.MOVING
	

func _unhandled_input(event):
	if event.is_action("Click"):
		var mouse_position = get_viewport().get_mouse_position()
		target_position = get_target_position(mouse_position)

func get_target_position(mouse_position: Vector2) -> Vector3:
	var ray_length = 999
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query)
	return result.position
	
	

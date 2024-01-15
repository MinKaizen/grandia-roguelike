extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var max_speed := 5.0
var acceleration := 10.0
var target_positions := [
	Vector3(-8, 0, 3),
	Vector3(8, 0, 3),
]
var target_index := 0
var target_position = target_positions[target_index]
var speed := 0.0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	var direction = (target_position - global_position).normalized()
	speed = move_toward(speed, max_speed, acceleration)
	velocity = direction * speed
	
	if (global_position.distance_to(target_position) < 3):
		target_index = (target_index + 1) % target_positions.size()
		target_position = target_positions[target_index]
	
	move_and_slide()

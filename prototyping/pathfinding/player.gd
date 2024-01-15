extends CharacterBody3D

var speed = 10.0
var accel = 20

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3

@onready
var nav = $NavAgent

@onready
var camera: Camera3D = owner.get_node("Camera")

@onready
var target_position = global_position

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	nav.target_position = target_position
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)

	move_and_slide()

func _unhandled_input(event):
	if event.is_action("Click"):
		var mouse_position = get_viewport().get_mouse_position()
		target_position = get_target_position(mouse_position)
		print(target_position)

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
	
	

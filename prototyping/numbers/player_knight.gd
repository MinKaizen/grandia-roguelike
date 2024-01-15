extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var speed := 10.0
@export var acceleration := 30.0
@export var timeline_speed := 30.0

@onready var move_command = $MoveCommand
@onready var camera = get_tree().get_first_node_in_group('camera')
@onready var timeline = $TimelineActor

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_action('ui_accept'):
		var move_to = get_ground_position(event.position)
		if move_to is Vector3:
			move_command.execute(move_to)

func get_ground_position(mouse_position: Vector2):
	var ray_length = 999
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space = get_tree().root.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query)
	if not 'position' in result:
		return null
	return result.position

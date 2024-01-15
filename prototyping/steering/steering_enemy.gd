extends CharacterBody3D


@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var camera: Camera3D = $"../Camera3D"
@onready var detector: Node = $ObstacleDetector

var speed = 10.0
var accel = 20
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3
var target_index = 0
var steering_radius = 1

var targets = [
	Vector3(4, 2, 4),
	Vector3(4, 2, -4),
]

#func _ready():
#	detector.connect('body_entered', func(body):
#		print('body entered! %s' % body)
#	)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	nav.target_position = get_target_position()
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	move_and_slide()

func get_target_position() -> Vector3:
	var target = targets[target_index]
	if global_position.distance_to(target) < 0.5:
		target_index = (target_index + 1) % targets.size()
		target = targets[target_index]
	return target
	
	

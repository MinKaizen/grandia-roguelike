extends CharacterBody3D

signal turn_ended

var speed = 10.0
var accel = 20

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3
var my_turn := false

@onready
var nav = $Nav

@onready
var camera: Camera3D = owner.get_node("Camera")

@onready
var target_position = global_position

@onready
var turn_manager = owner.get_node('TurnManager')

func _ready():
	turn_manager.connect('turn_input', self._on_turn_input)
	turn_manager.connect('next_turn', func(actor):
		my_turn = actor == self
		if my_turn:
			print('%s: my turn!' % name)
	)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	nav.target_position = target_position
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)

	move_and_slide()

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
	
func _on_turn_input(event, actor):
	if not actor == self or not my_turn:
		return
	if event.is_action_pressed("Click"):
		print('%s: received click' % name)
		var mouse_position = get_viewport().get_mouse_position()
		target_position = get_target_position(mouse_position)
		my_turn = false
		print('%s: turn finished' % name)
		emit_signal('turn_ended')

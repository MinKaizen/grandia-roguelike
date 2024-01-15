extends Control

signal choice_selected

enum COMMAND {NONE, MOVE, ATTACK}
enum STATE {IDLE, CHOOSE_COMMAND, CHOOSE_TARGET}

@export var actor: Node

var state = STATE.IDLE
var command = COMMAND.NONE
@onready var camera = get_tree().get_first_node_in_group('camera')

func _ready():
	hide()
	actor.connect('choice_time', func():
		get_tree().paused = true
		show()
		state = STATE.CHOOSE_COMMAND
	)
	
	$Center/ChoiceContainer/MoveButton.connect('button_down', func():
		hide()
		state = STATE.CHOOSE_TARGET
		command = COMMAND.MOVE
	)

	$Center/ChoiceContainer/AttackButton.connect('button_down', func():
		hide()
		state = STATE.CHOOSE_TARGET
		command = COMMAND.ATTACK
	)

func _unhandled_input(event):
	if state != STATE.CHOOSE_TARGET:
		return
	if command == COMMAND.MOVE and event.is_action_pressed('Click'):
		var mouse_position = get_viewport().get_mouse_position()
		var target_position = get_target_position(mouse_position)
		get_tree().paused = false
		emit_signal('choice_selected', 'move', target_position)
	if command == COMMAND.ATTACK and event.is_action_pressed('Click'):
		var mouse_position = get_viewport().get_mouse_position()
		var target = get_target(mouse_position)
		if target != null:
			get_tree().paused = false
			emit_signal('choice_selected', 'attack', target)
		else:
			print('Invalid attack target')

func get_target_position(mouse_position: Vector2) -> Vector3:
	var ray_length = 999
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space = get_tree().root.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query)
	return result.position

func get_target(mouse_position: Vector2):
	var ray_length = 999
	var space = get_tree().root.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = camera.project_ray_origin(mouse_position)
	ray_query.to = ray_query.from + camera.project_ray_normal(mouse_position) * ray_length
	# Collision mask: characters
	ray_query.collision_mask = 2
	var result = space.intersect_ray(ray_query)
	
	if result.has('collider'):
		return result.collider
	
	return null

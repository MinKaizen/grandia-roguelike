extends CharacterBody3D

@export_range(0.1, 2.0) var damage_interval: float = 1.0
@export_range(10, 50) var min_damage: int = 10
@export_range(20, 1000) var max_damage: int = 100

const SPEED = 5.0
@onready var timer = $Timer
@onready var damage_number_scene = load('src/damage_number.tscn')
@onready var camera = get_tree().get_first_node_in_group('camera')
var direction := Vector3(0, 0, 1)

func _ready():
	timer.autostart = true
	timer.wait_time = damage_interval
	timer.start()
	timer.connect('timeout', func():
		var damage_number = damage_number_scene.instantiate()
		get_tree().root.add_child(damage_number)
		damage_number.init(calculate_damage(), self.global_position, camera)
	)
	if min_damage > max_damage:
		print("Warning: %s max_damage is less than min_damage. max_damage set to 100" % name)
		max_damage = 100

func calculate_damage():
	return randi_range(min_damage, max_damage)

func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = direction.rotated(Vector3(0, 1, 0), PI/2 * delta)
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED


	move_and_slide()
